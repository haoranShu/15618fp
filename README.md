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

	1. Read In, Re-order and Store data
	2. Gather Weight of Pixels
	3. Reduce Gathered Results and Render to Image

### Key Data Structures

To minimize work, we used **QuadTrees** (QuadForests) to store the data points, both in CPU sequential version and CUDA parallel version. A **heatmap\_t** data structure is used to store the accumulated weights of each pixel for each QuadTree in the forest. A **colorscheme\_t** data structure is used to map weights to proper colors according to its ranking within all the weights on the plot.

#### QuadTree

> (WikiPedia) A quadtree is a tree data structure in which each internal node has exactly four children. 

We use each QuadTree node to represent a rectangle on the region we are going to render. Each node of the QuadTree would correspond to a subset of the whole dataset and a node stops splitting itself when the number of data points within that node is less than a pre-selected threshold or a pre-defined maximum depth of QuadTree is reached. QuadTree is widely used for its **search** operation that outputs the points of a dataset that are within a rectangle in O(logN) time.

![alt text](https://github.com/jyzhe/15618fp/blob/final/selected_quad.png "Logo Title Text 1")
(by Mike Bostock https://bl.ocks.org/mbostock/4343214)

Using a QuadTree enables a finer control over the interactions between pixels and data points. Now we do not have to iterate through the whole dataset to gather the accumulated density at a pixel. Instead, we can traverse the QuadTree and consider points in a given small vicinity of the pixel.

In our program, we implemented a linear QuadTree that which is actually a series of re-ordering among the data points. Thus each tree node effectively points to a continuous chunk of data points in the dataset. Following is a z-order illustration of this re-ordering.

![alt text](https://github.com/jyzhe/15618fp/blob/final/z-order.001.jpeg "Logo Title Text 1")

1. **Main Operations**

	1. buildQuadTree

	This function builds a QuadTree at most MAX_DEPTH deep with the given points, and each leaf has at most MIN\_NUM\_PER\_NODE points.

	2. overlaps

	Each QuadTree node has a bounding box which corresponds to a rectangle in the data space. This function checks if a region in data space overlaps with the bounding box of the QuadTree node.

	3. traverse

	This function **recursively** traverses the QuadTree and gathers for a pixel the interesting  weights of nearby data points.

2. **Implementation**

Parallel QuadTree is an interesting parallel project in its own rights so we did not plan to implement a parallel building algorithm for QuadTree. We are satisfied with a on-GPU QuadTree data structure. Thus we implemented a CPU serial QuadTree data structure. However, to speedup tree building on large datasets, we used a cdqQuadTree implementation **provided by Nvidia**. That, however, is a **buggy** implementation and only concerns with building a QuadTree from data points.

The implementation uses CUDA Dynamic Parallism to build a QuadTree in parallel. It uses two buffers to hold the data points throughout the process of re-ordering, and uses shared memory to keep track of corresponding data points' offset in the buffer for threads in each warp.

#### Colormap

> We used the colormap library from https://github.com/lucasb-eyer/heatmap (maintained by lucasb-eyer)

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

![alt text](https://github.com/jyzhe/15618fp/blob/final/para1.001.jpeg "Logo Title Text 1")

The advantage of this parallelism is obvious:

1. There is no data contention in this model. Although each point may affect several pixels and thus points are not independent, each pixel is independent from other pixels. In the process of QuadTree traversal and weight gathering, only READ is performed on the shared data structure, the QuadTree. WRITEs are only performed to different locations of a shared buffer so there is no contention.

2. We usually have a large amount of pixels so that we are chopping our work into chunks, supposedly, small enough.

**However, this strategy does not give us a good speedup. In fact, the performance of our parallel code can even be slower than the sequential CPU code on some datasets.**

We looked into the code and found out that the main **problems** with this embarassing parallelism are multiple:

1. **Inbalance Workload** The data points are very likely to be skewed in the data space. As a matter of fact, the skewedness in distribution is what people are looking for most of the time. Thus, parallelizing on pixels may suffer from this inbalance. A remedy is to assign multiple pixels to one thread with a relatively large stride within these pixels on the same thread (because nearby pixels tend to have similar workload).

2. **Poor SIMD Parallelism** CUDA is good at performing SIMD operations. In our case, however, although the kinds of work each pixel does are similar, calling a recursive traverse function makes it highly probable for threads in the same warp to diverge to different branches in the function. In the worst case, this can even make a warp sequential in its execution.

3. **Redundant Work on Points** The avoidance of contention comes at a cost: we are processing each point multiple times (81 times at most, to be precise). This is because each point weighs in for all pixels surrounding it. What is worse, when we traverse the QuadTree, we are not only processing the points that really eventually weight in, but also checking other points in the same node and then the redundancy in work multiplies.

4. **Limitation of QuadTree and Revursive Functional Calls on GPU** The linear QuadTree data structure can take up a lot of space on GPU because it assumes that the tree is complete and thus allocate spaces for each node even if it does not exist. Also, since CUDA does not know the stack size to allocate for a recursive function call (not dynamically nested kernel launch), there is a limit in the depth of recursion. Both factors limit the MAX\_DEPTH of the QuadTree we can build. This becomes a huge problem when the dataset grows in size and the data points are skewed: we have to increase the MIN\_NUM\_POINTS\_PER\_NODE to accomodate all the points. This is against the motivation why we use a QuadTree at the first place: we want to minimize the points we probed, but if the QuadTree is too shallow, this minimization results in nothing really minimal.

### Parallel on Data Points
Thinking about the problems we had with our first try, we decided to work on problem 1, 3 and 4. We had little idea what we can do to take more advantage of the SIMD nature of CUDA model because our problem is not computation intensive in nature. It is only large in data.

This time, we add in parallelism on the data points, while we do not abandon the parallelism on points at all. The way we do this is to build multiple QuadTrees, each storing a part of the dataset. This remedies the load inbalance problem because chunks of work are finer-grained now. Less redundancy on points because we parallelize on them (this might be harder to explain, but imagine at the extreme case where each tree has only one point, we are doing no extra work on points). Although we still cannot go any deeper into the recursion, we have reduced the total amount of data in each QuadTree and thus minimized number of points to probe.

Also, we only gather weights of points directly reside in the calling pixel at the first kernel. This proves to reduce running time effectively.

Precisely, we do the following:

* Divide the data into NUM\_TREES chunks and build NUM\_TREES QuadTrees to hold them

* Allocate a temporary buffer to store local gathered weights on each pixel for each chunk of data points

* Launch kernel with NUM\_TREES blocks, each block responsible for one chunk of data, within each block, each thread is responsible for work of a number of pixels independently

* Reduce the weights onto one buffer

* Apply stamp on the reduced buffer

* Calculate the maximum weight on image, scale the weights and render

![alt text](https://github.com/jyzhe/15618fp/blob/final/para2.001.jpeg "Logo Title Text 1")

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

![alt text](https://github.com/jyzhe/15618fp/blob/final/zoomin.jpeg "Logo Title Text 1")

### Performance

![alt text](https://github.com/jyzhe/15618fp/blob/final/plot3.png "Logo Title Text 1")

![alt text](https://github.com/jyzhe/15618fp/blob/final/plot2.png "Logo Title Text 1")

![alt text](https://github.com/jyzhe/15618fp/blob/final/plot1.png "Logo Title Text 1")


### Future Work

1. There are still ways to optimize our algorithm but we do not have enough time to carry them out. If we got chance, we can play with ideas like putting the QuadTree on CPU and the Points on GPU (QuadTree actually only stores indices). 

2. We are both having problem with the X forwarding functionality of the GHC machines so we did not try out our OpenGL utilities with CUDA. But since we can always bind a device buffer mapped to CUDA with a texture of OpenGL, this should work easily.

## COOPERATION

Haoran and Jay are both actively involved in this project and the overall ratio of division is 50:50.

Haoran is mainly responsible for setting up the structure of the program, generating test datasets, OpenGL utility implementation and CUDA render and reduce kernels.

Jay (Zhe) is mainly responsible for implementing the QuadTree data structure on both CPU and GPU, and the implementation of CUDA traverse and stamp mapping kernel.

## REFERENCES

* Large Interactive Visualization of Density Functions on Big Data Infrastructure. Alexandre Perrot, et al. 2015

* Interactive Visualization of High Density Streaming Points with Heat-map. Chenhui Li, et al. 2014

* cdpQuadtree Implementation by Nvidia