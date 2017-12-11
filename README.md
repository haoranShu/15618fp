# ParaViz - A Parallel Solution to Meaningful Visualization of Large Datasets

## Summary

We implemented an interactive large dataset visualization pipeline with CUDA and compared its performace with optimized CPU sequential version. It is able to render millions of points within milliseconds, and to re-render to different levels of details realtime.

## BACKGROUND

Recently scientists' ability to collect and process large datasets have been growing rapidly, marking an increasing need for effective and efficient visualization tools on large datasets. Visualization of large datasets differs greatly from traditional visualization in many aspects, apart from their obvious difference in size. For point set visualization, for example, point occlusion makes it hard to generate effective and honest presentation of a million-level dataset in a laptop screen. Also, interactive visualization may require re-computation on each level of detail. Sometimes, it is even hard to load the whole dataset into memory, when we have to resort to distributed clusters. All these factors make visualization on large datasets a topic of interest and a great objective for parallel computing.

> An overplotted figure and a heatmap

Among various visualization problems on large datasets, we chose to work on the Interactive Visualization of Heatmaps because of both the its popularity, as a method to represent big data, among different kinds of datasets, and its well-definedness to guide our project.

More formally, a heatmap is a continuous representation of discrete point sets. It takes advantage of function estimation techniques to generate a density function of the input data and map it to a predefined color scheme. It is widely used to represent data pertaining to geographic distribution of information, providing easy-to-read plots.

### Program Overview

Our program takes as input a list of 2-dimensional data points with weights together with the desired window position and size, and outputs the corresponding heatmap.

As for the interactive part, it provides a zoom-in/out and drag feature that enables local scrutinization of the dataset, with a suitable level of detail.

We ran all our experiments on the GHC machines but our OpenGL utility can only run on our laptops because of some problems on the GHC machines. Thus, we simulated the zoom-in/out and drag functionality with another input of interaction tracefile, which includes a series of queries to our renderer at different positions of the data with different level of detail requirement.

> GIF inserted here

#### Workflow

Our workflow involves mainly three steps:

1. Read In, Re-order and Store data
2. Gather Weight of Pixels
3. Reduce Gathered Results and Render to Image

### Kernel Density Estimation and Its Approximation

Here

### Key Data Structures

To minimize work, we used **QuadTrees** (QuadForests) to store the data points, both in CPU sequential version and CUDA parallel version. A **heatmap\_t** data structure is used to store the accumulated weights of each pixel for each QuadTree in the forest. A **colorscheme\_t** data structure is used to map weights to proper colors according to its ranking within all the weights on the plot.

#### QuadTree

> (WikiPedia) A quadtree is a tree data structure in which each internal node has exactly four children. 

We use each QuadTree node to represent a rectangle on the region we are going to render. Each node of the QuadTree would correspond to a subset of the whole dataset and a node stops splitting when the number of data points within that node is less than a pre-selected threshold or a pre-defined maximum depth of QuadTree is reached. QuadTree is widely used for its **search** operation that outputs the points of a dataset that are within a rectangle in O(logN) time.

> Illustration of QuadTree

Using a QuadTree enables a finer control over the interactions between pixels and data points. Now we do not have to iterate through the whole dataset to gather the accumulated density at a pixel. Instead, we can traverse the QuadTree and consider points in a given small vicinity of the pixel.

##### Main Operations
1. buildQuadTree
2. overlaps
3. traverse

##### Implementation



##### Parallelism



#### Heatmap

##### Main operations

##### Implementation

##### Parallelism
reduction (sum & max)


#### Colorscheme

##### Parallelism
writeToImage

#### Performance Breakdown

## APPROACH


## RESULTS

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

