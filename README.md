# ParaViz - A Parallel Solution to Meaningful Visualization of Large Datasets

## Summary

We implemented an interactive large dataset visualization pipeline with CUDA and compared its performace with optimized CPU sequential version. It is able to render millions of points within milliseconds, and to re-render to different levels of details realtime.

## BACKGROUND

Recently scientists' ability to collect and process large datasets have been growing rapidly, marking an increasing need for effective and efficient visualization tools on large datasets. Visualization of large datasets differs greatly from traditional visualization in many aspects, apart from their obvious difference in size. For point set visualization, for example, point occlusion makes it hard to generate effective and honest presentation of a million-level dataset in a laptop screen. Also, interactive visualization may require re-computation on each level of detail. Sometimes, it is even hard to load the whole dataset into memory, when we have to resort to distributed clusters. All these factors make visualization on large datasets a topic of interest and a great objective for parallel computing.

![alt text](https://github.com/jyzhe/15618fp/blob/final/overplotted.png "Logo Title Text 1")

(By Jeffrey Heer and Sean Kandel)

Among various visualization problems on large datasets, we chose to work on the Interactive Visualization of Heatmaps because of both the its popularity, as a method to represent big data, among different kinds of datasets, and its well-definedness to guide our project.

More formally, a heatmap is a continuous representation of discrete point sets. It takes advantage of function estimation techniques to generate a density function of the input data and map it to a predefined color scheme. It is widely used to represent data pertaining to geographic distribution of information, providing easy-to-read plots.

### Program Overview

Our program takes as input a list of weighted 2-dimensional data points together with the desired window position and size, and outputs the corresponding heatmap.

As for the interactive part, it provides a zoom-in/out and drag feature that enables local scrutinization of the dataset, under a suitable level of detail.

We ran all our experiments on the GHC machines but our OpenGL utility can only run on our laptops because of some problems with the X-forwarding on the GHC machines. Thus, we simulated the zoom-in/out and drag functionality with another input of interaction tracefile, which includes a series of queries to our renderer at different positions of the data with different level of detail requirement. An example illustration is posted below.

![alt text](https://github.com/jyzhe/15618fp/blob/final/ezgif.com-video-to-gif.gif "Logo Title Text 1")

#### Workflow

Our workflow involves mainly three steps:

* Read In, Re-order and Store data
* Gather Weight of Pixels
* Reduce Gathered Results and Render to Image

> workflow illustration

### Key Data Structures

To minimize work, we used **QuadTrees** (QuadForests) to store the data points, both in CPU sequential version and CUDA parallel version. A **heatmap\_t** data structure is used to store the accumulated weights of each pixel for each QuadTree in the forest. A **colorscheme\_t** data structure is used to map weights to proper colors according to its ranking within all the weights on the plot.

#### QuadTree

> (WikiPedia) A quadtree is a tree data structure in which each internal node has exactly four children. 

We use each QuadTree node to represent a rectangle on the region we are going to render. Each node of the QuadTree would correspond to a subset of the whole dataset and a node stops splitting itself when the number of data points within that node is less than a pre-selected threshold or a pre-defined maximum depth of QuadTree is reached. QuadTree is widely used for its **search** operation that outputs the points of a dataset that are within a rectangle in O(logN) time.

![alt text](https://github.com/jyzhe/15618fp/blob/final/selected_quad.png "Logo Title Text 1")
(by Mike Bostock https://bl.ocks.org/mbostock/4343214)

Using a QuadTree enables a finer control over the interactions between pixels and data points. Now we do not have to iterate through the whole dataset to gather the accumulated density at a pixel. Instead, we can traverse the QuadTree and consider points in a given small vicinity of the pixel.

In our program, we implemented a linear QuadTree that which is actually a series of re-ordering among the data points. Thus each tree node effectively points to a continuous chunk of data points in the dataset. Following is a z-order illustration of this re-ordering.

![alt text](https://github.com/jyzhe/15618fp/blob/final/z-order.png "Logo Title Text 1")

1. **Main Operations**
* buildQuadTree

	This function builds a QuadTree at most MAX\_DEPTH deep with the given points, and each leaf has at most MIN\_NUM\_PER\_NODE points.

* overlaps

	Each QuadTree node has a bounding box which corresponds to a rectangle in the data space. This function checks if a region in data space overlaps with the bounding box of the QuadTree node.

* traverse

	This function **recursively** traverses the QuadTree and gathers for a pixel the interesting  weights of nearby data points.

2. **Implementation**

Parallel QuadTree is an interesting parallel project in its own rights so we did not plan to implement a parallel building algorithm for QuadTree. We are satisfied with a on-GPU QuadTree data structure. Thus we implemented a CPU serial QuadTree data structure. However, to speedup tree building on large datasets, we used a cdqQuadTree implementation **provided by Nvidia**. That, however, is a **buggy** implementation and only concerns with building a QuadTree from data points.

The implementation uses CUDA Dynamic Parallism to build a QuadTree in parallel. It uses two buffers to hold the data points throughout the process of re-ordering, and uses shared memory to keep track of corresponding data points' offset in the buffer for threads in each warp.

#### Colormap

> Credit to Repo

## APPROACH

### Kernel Density Estimation and Its Approximation
KDE is widely used to compute the density function of a point set. Using a kernel function, we can generate a continuous function from a discrete point set. The formula of classical KDE is as the following,

![alt text](https://github.com/jyzhe/15618fp/blob/final/KDE.jpeg "Logo Title Text 1")

Do the exact calculation can be slow because of the floating point mathematical operations it involves. Therefore, we use an discretized approximation of the classical KDE. Instead of weighing a data point with respect to its Euclidean distance to the centered of the pixel (mapped to the data space), we discretize this distance by pixels (by width/height of a pixel in the data spacd) and precompute a finite number of weights for each pixel around the residing pixel of the concerned point. In our program we chose a 9-pixel by 9-pixel stamp simulating a Gaussian Kernel.

![alt text](https://github.com/jyzhe/15618fp/blob/final/KDE_stamp.jpeg "Logo Title Text 1")

### QuadTree on GPU

One problem about using CUDA is that we need to transfer a huge amount of data between the CPU and GPU. If we are going to do this transfer of data each time the user queries a zoom/drag, it is hard to make our program interactive in realtime, especially with large datasets. Thus, we decided to put the QuadTree on GPU, so that we do not move data back and forth.

The Nvidia implementation of QuadTree we made use of in our program is a very inspiring implmentation with CUDA. Thanks a lot for the buggy but beautiful implementation.

### Parallel on Pixels
First we tried to parallize our algorithm over each pixel. The idea is natural for any rendering problem. Given a fixed stamp, each pixel is affected by points that are mapped to the 9-pixel by 9-pixel window centered at this pixel (note there is a mapping from the data space to the rendering space). Our approach is to build **one** QuadTree on GPU and store all points in it. Then, for each pixel we traverse the QuadTree with the data space region corresponding to 81-pixel window centered at this pixel for points that might weigh in for this pixel. For each point probed, calculate its distance to the center of the calling pixel in data space and add a fraction of its weight to the total weight of the pixel according to the stamp.

A little optimization we make is that, for the common case where a whole node's bounding box is contained in a pixel, we just add a fraction of the sum of weights of points in this node to the calling pixel so that we can stop our traversal early. Note that we already discretized our KDE with a stamp, so this simplification would make no difference on the result.

> illustration

The advantage of this parallelism is obvious:

1. There is no data contention in this model. Although each point may affect several pixels and thus points are not independent, each pixel is independent from other pixels. In the process of QuadTree traversal and weight gathering, only READ is performed on the shared data structure, the QuadTree. WRITEs are only performed to different locations of a shared buffer so there is no contention.

2. We usually have a large amount of pixels so that we are chopping our work into chunks, supposedly, small enough.

>5. performance: only as good as CPU version, sometime even slower
>
> plot?

The main **problems** with this embarassing parallelism are multiple:

1. **Inbalance Workload** The data points are very likely to be skewed in the data space. As a matter of fact, the skewedness in distribution is what people are looking for most of the time. Thus, parallelizing on pixels may suffer from this inbalance. A remedy is to assign multiple pixels to one thread with a relatively large stride within these pixels on the same thread (because nearby pixels tend to have similar workload).

2. **Poor SIMD Parallelism** CUDA is good at performing SIMD operations. In our case, however, although the kinds of work each pixel does are similar, calling a recursive traverse function makes it highly probable for threads in the same warp to diverge to different branches in the function. In the worst case, this can even make a warp sequential in its execution.

3. **Redundant Work on Points** The avoidance of contention comes at a cost: we are processing each point multiple times (81 times at most, to be precise). This is because each point weighs in for all pixels surrounding it. What is worse, when we traverse the QuadTree, we are not only processing the points that really eventually weight in, but also checking other points in the same node and then the redundancy in work multiplies.

4. **Limitation of QuadTree and Revursive Functional Calls on GPU** The linear QuadTree data structure can take up a lot of space on GPU because it assumes that the tree is complete and thus allocate spaces for each node even if it does not exist. Also, since CUDA does not know the stack size to allocate for a recursive function call (not dynamically nested kernel launch), there is a limit in the depth of recursion. Both factors limit the MAX\_DEPTH of the QuadTree we can build. This becomes a huge problem when the dataset grows in size and the data points are skewed: we have to increase the MIN\_NUM\_POINTS\_PER\_NODE to accomodate all the points. This is against the motivation why we use a QuadTree at the first place: we want to minimize the points we probed, but if the QuadTree is too shallow, this minimization results in nothing really minimal.

### Parallel on Data Points
Thinking about the problems we had with our first try, we decided to work on problem 1, 3 and 4. We had little idea what we can do to take more advantage of the SIMD nature of CUDA model because our problem is not computation intensive in nature. It is only large in data.

This time, we add in parallelism on the data points, while we do not abandon the parallelism on points at all. The way we do this is to build multiple QuadTrees, each storing a part of the dataset. This remedies the load inbalance problem because chunks of work are finer-grained now. Less redundancy on points because we parallelize on them (this might be harder to explain, but imagine at the extreme case where each tree has only one point, we are doing no extra work on points). Although we still cannot go any deeper into the recursion, we have reduced the total amount of data in each QuadTree and thus minimized number of points to probe.

Also, we only gather weights of points directly reside in the calling pixel at the first kernel. This proves to reduce running time effectively.

Precisely, we do the following:

1. Divide the data into NUM\_TREES chunks and build NUM\_TREES QuadTrees to hold them

2. Allocate a temporary buffer to store local gathered weights on each pixel for each chunk of data points

3. Launch kernel with NUM\_TREES blocks, each block responsible for one chunk of data, within each block, each thread is responsible for work of a number of pixels independently

4. Reduce the weights onto one buffer

5. Apply stamp on the reduced buffer

6. Calculate the maximum weight on image, scale the weights and render

> illustration

This strategy works well for our problem so its optimized performance will be reported in the next section. Here we also analyze its existing problems.

1. **Requirement on Data Size** This works well on large data sets only. When the data set is small, the overhead may prevail. (By small we mean less than 1 million)

3. **Further Reduction Needed** In step 4 we have to reduce the local results to global buffer. This is additional work, but it should be fast on CUDA.

### Parallel Reduction

There are two point in our algorithm that we need to reduce through an array of data. First, before rendering to image, we need to normalize the weights with respect to the maximum weight gathered in the window. Second, we need to add the weights in local results to a global result. We could have used thrust library but we decided to write this part by ourselves. We did take advice from a Nvidia tutorial online (http://developer.download.nvidia.com/compute/cuda/1.1-Beta/x86_website/projects/reduction/doc/reduction.pdf).

Two tricks we applied are:

1. **Use of Shared Memory** For each block, we first let each thread reduce a portion of the input and store the result in a shared memory. Then we reduce the intermediate results in the shared memory using a sequential addressing manner (shown below) because it does not mess with the shared memory bank.

![alt text](https://github.com/jyzhe/15618fp/blob/final/reduction.png "Logo Title Text 1")
(by Nvidia)

2. **Use of Warp Parallelism (SIMD) and Unrolling** When the reduction comes down to **warpSize**, we drop **__syncthreads** because SIMD ensures that they would complete simultaneuosly. We also unroll the loops so that they can be faster.

## RESULTS

### Outputs

### Performance
	- table of 10w, 100w, 1000w, 5000w data point CPU/GPU time

	- Plot of 10w, 100w, 1000w, 5000w speedup

	- Graph of 10w, 100w, 1000w, 5000w time breakdown

### Future Work

1. put QuadTree on CPU and send point begin / end to GPU only

## COOPERATION

## REFERENCES





1. **Consistency Requirement**:
Processing different portion of input data on different machines introduces the problem of non-consistency in the resulting visualizations. How to reconcile the discrepancies on border of plot blocks becomes a problem and might require additional synchronization and communication, which may increase the latency of our algorithm.

1. **Interactive Visualization**:
It is necessary to provide an interactive interface for users so that they can scrutinize the data at different levels. This is typically enabled by computing corresponding visualizations of different levels of detail and provide most suitable version to users statically. It would save a lot of computation and offer better results if we can compute on the fly dynamically, on the basis of some rawly pre-computed results, but this strategy requires faster communication.

## Resources

* We are planning to start this project by extending the serial heatmap generation library (https://github.com/lucasb-eyer/heatmap). This is a simple heatmap library written in C that allows various customizations. We believe that parallelization on this library is both interesting and feasible because as the data gets larger and larger, generating the heatmap and allowing user interactions becomes impossible. We are also planning to implement visualization on web browsers, there might be some existing web frameworks that we will need to look into to expedite the development process and focus on the potential parallelism of our implementation.

* Reference: Research on Heatmap for Big Data Based on Spark, Zhang Fan, Yuan Zhaokang, Xiao Fanping, You Kun, Wang Zhangye, Journal of Computer-Aided Design & Computer Graphics. Vol. 28, No. 11, November 2016.

* One of the most important resource that we need is the dataset for the heatmap. The heatmap generation library used DOTA2 replay files as its sample dataset, which we belive is also a good candidate dataset to consider. First of all, the amount of DOTA2 replay files is very large, and we can obtain as much data as we need during different stages of the project development. The replay files can also be categorized easily according to game version number, role of the characters in the game, regions etc. This will be useful in the later stages where we develop an interactive interface.

* As opposed to the previously proposed plan of building an infrastructure using Spark from scratch, we plan to do most of the processing using MPI. We might need to run our code on latedays to provide better support for parallelism.

## Goals and Deliverables

### Plan to achieve

1. Come up with a way to separate the dataset into different tiles of different resolutions to allow parallel processing and interactive manipulation of the heatmap. Collect dataset of DOTA2 replays.

1. Parallel process of the data and parallelize the serial version of the heatmap generator library.

1. Use the processed data, generate a heatmap visualization using WebGL JavaScript Library and add various interactive features, such as zoom in/out, change time frame of interest.

### Hope to achieve

1. Instead of using a single dataset, allow users to add new replay files that are incorporated into the dataset.

### Demo

We plan to demo our web application that displays a heatmap representation of our dataset and allows the user to zoom in and out and manipulate the time of interest. We will show the size of our dataset and the computation required for the interactive demo. We might also show the speed up graph of generating the heatmap using Apache Spark and WebGL.

## Platform of Choice

### Data Processing
We plan to use MPI for this part of the project as it provides a convenient and fast way of processing large scale data. We need MPI as the size of the data set is too large to fit in any single machine and demands too much computational resource to generate the heatmap.

### Data Visualization

We plan to use WebGL JavaScript Library for this part of the project as it provides API for rendering **interactive** 3D and 2D graphics that fit our needs. 

## Checkpoint Report

### Progress So Far

In the past three weeks, we mainly spent our time reading related literature on our project, designing our own pipeline, looking for appropriate datasets and playing around the starter codes we found. Up to this point, we have decided on our main pipeline design and the main data structures that we are going to use. We also have finished several attempts to parallize the starter code (heatmap rendering) part using OpenMP. Following is a more detailed description of our pipeline design and targeted datasets.

#### Pipeline Design

We mainly devided our pipeline into three parts: Binning, Level of Detail Building and Kernel Density Estimation Rendering. When the gap between output plot size and dataset size is large, we perform binning to cluster points that would be rendered to the same pixel. For use of hierarchincal interaction, we build several levels of details in a Pyramid-like construct. Finally, we render the datapoints using KDE to handle the problem of overplotting and cluttering.

For both Binning and LoD Building we plan to use a QuadTree data structure so that the computational complexity could be reduced to O(logn) even without parallelism. Using GPU, we can further reduce the complexity to constant time.

For KDE Rendering we plan to try out both OpenMP and CUDA. We have already implemented it with OpenMP and a detailed performance report is in the next section.

#### Datasets

We will be using two datasets: DOTA2 replays and SNAP (Stanford Network Analysis Project) datasets (using nodes only). The first dataset is used in the starter code we found and can serve as a benchmark dataset for us to test our speedup with respect to the original serial implementation. The latter is larger in size and provides temporal data, which make it ideal for both ends of interaction and time-dependent streaming in our goals.

### Preliminary Results

We first tried to parallelize the starting codes (the KDE rendering part) with OpenMP. We tried a couple of approaches and found out they each performs better with different sizes of data input.

First, we tried to parallelize the update function for each data point. This resulted in a much slower runtime due to the fact that the update requires very little computation for each data point, thus making parallelization ineffective. 

Since we are mostly limited by the overlapping datapoints that update the same pixels, our second intuition was to reduce this contention and improve our speed up. We tried to parallelize the program by separating the heatmap into distinct blocks so that updates to the heatmap can be carried out concurrently with minimal contention between the blocks. However, when the number of data points are large, each thread will need to traverse the entire list of points a couple of times, resulting in unsatisfactory speedup.

Next, we tried to preprocess the input data points and group similar points together before performing the actual reduction. This resulted in a much better speed up (100 million points only takes about 0.5 second, compared to the sequential version which takes about 15 seconds). Grouping the data points is also a nice segue to the next phase of the project as we will need to support zoom in and zoom out and therefore heatmaps of differnet resolutions. Grouping will be helpful for rendering different heatmaps quickly for the demo.

### Updated Project Goals and Methods

We were planning to use MPI at first, but downsizing the datasets makes Shared Address Space models interesting as well. Thus we plan to use OpenMP and CUDA first for the two datasets stated above. If time permits, we will implement an MPI version to SIMULATE the scenario where dataset is too large.

We still aim to accomplish other goals in our original proposal, including zooming interactions and time-frame selection.

### Main Concerns

Currently the rendering step of heatmap generation requires very little computation for each data point as only a 9 by 9 region would need to be updated. As a result, our parallel implementation using OpenMP did not show a significant reduction in terms of the run time due to the overhead of parallel implementation. We have a number of choices in the next phase. First, we could use more data points. This would increase the computation required to generate the heatmap, but at the same time, using too many data point may saturate the image, therefore, reducing the quality of the heatmap. We could also use a larger stamp. This larger stamp can be applied to an image of greater resolution to increase the computational complexity of generating the heatmap, therefore, improving the observed speedup. This approach may be preferred. We shall also explore the implementation using Cuda as updating the heatmap fits naturally with the SIMD design of a Cuda program. 


## Updated Schedule

**Week 4 (11.20 - 11.26)**

	Task: QuadTree Implementation (Jay)
	Task: CUDA KDE Renderer Implementation (Haoran)
	Task: Hierarchical Level of Details Implementation (Haoran)

**Week 5 (11.27 - 12.3)**

	Task: Interaction GUI Implementation (Jay)
	Task: Parallelize QuadTree (Jay and Haoran)

**Week 6 (12.4 - 12.10)**

	Task: Further Optimizations (Jay and Haoran)
	Task: Experiments (Jay and Haoran)

