# ParaViz - A Parallel Solution to Meaningful Visualization of Large Datasets

## Summary

We are going to implement a Parallel Iteractive Visualization of Heatmap on Large Datasets on Web Browsers, using a Shared Nothing Architecture like Latedays with a Message Passing Paradigm.

## Background

Recently scientists' ability to collect and process large datasets have been growing rapidly, marking an increasing need for effective and efficient visualization tools on large datasets. Visualization of large datasets differs greatly from traditional visualization in many aspects, apart from their obvious difference in size. For point set visualization, for example, point occlusion makes it hard to generate effective and honest presentation of a million-level dataset in a laptop screen. Also, interactive visualization may require re-computation on each level of detail. Sometimes, it is even hard to load the whole dataset into memory, when we have to resort to distributed clusters. All these factors make visualization on large datasets a topic of interest and a great objective for parallel computing.

Among various visualization problems on large datasets, we chose to work on the Interactive Visualization of Heatmaps because of both the its popularity, as a method to represent big data, among different kinds of datasets, and its well-definedness to guide our project.

More formally, a heatmap is a continuous representation of discrete point sets. It takes advantage of function estimation techniques to generate a density function of the input data and map it to a predefined color scheme. It is widely used to represent data pertaining to geographic distribution of information, providing easy-to-read plots. Its easy-to-read property also makes it much more popular than other general visualization paradigms among non-scientist users on the Web, thus we planed to deliver an implementation on Web Browsers specifically.

## The Challenge
1. **Size of Data**:
The size of input data is the primary motivation for our project. Most of the time, the available dataset cannot be loaded into the memory of a single commodity machine and needs to be distributedly stored and processed. Although we might use downsized datasets in our projects, we are going to implement our algorithm with a Message Passing Paradigm to simulate this reality.

1. **Data Occlusion**:
Data Occlusion happens when the amount of data is much larger than the amount of usable pixels in our screen (or human eyes) so that it is hard to differentiate beween dense areas of the visualization, where huge differences might actually exist. It is at the core of providing "effective" visualizations and suitable pre-processing and sampling of datasets must be carried out. Coming with this need are limitations in our design of the algorithm because of the potential synchronization and communication it might require.

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

1. Pipeline Design
	We mainly devided our pipeline into three parts: Binning, Level of Detail Building and Kernel Density Estimation Rendering. When the gap between output plot size and dataset size is large, we perform binning to cluster points that would be rendered to the same pixel. For use of hierarchincal interaction, we build several levels of details in a Pyramid-like construct. Finally, we render the datapoints using KDE to handle the problem of overplotting and cluttering.

	For both Binning and LoD Building we plan to use a QuadTree data structure so that the computational complexity could be reduced to O(logn) even without parallelism. Using GPU, we can further reduce the complexity to constant time.

	For KDE Rendering we plan to try out both OpenMP and CUDA. We have already implemented it with OpenMP and a detailed performance report is in the next section.

2. Datasets
	We will be using two datasets: DOTA2 replays and SNAP (Stanford Network Analysis Project) datasets (using nodes only). The first dataset is used in the starter code we found and can serve as a benchmark dataset for us to test our speedup with respect to the original serial implementation. The latter is larger in size and provides temporal data, which make it ideal for both ends of interaction and time-dependent streaming in our goals.

### Preliminary Results

We first tried to parallelize the starting codes (the KDE rendering part) with OpenMP. We tried two methods and found out they each performs better with different sizes of data input.

### Updated Project Goals and Methods

We were planning to use MPI at first, but downsizing the datasets makes Shared Address Space models interesting as well. Thus we plan to use OpenMP and CUDA first for the two datasets stated above. If time permits, we will implement an MPI version to SIMULATE the scenario where dataset is too large.

We still aim to accomplish other goals in our original proposal, including zooming interactions and time-frame selection.

### Main Concerns



## Updated Schedule

**Week 4 (11.20 - 11.26)**

	Task: QuadTree Implementation
	Task: CUDA KDE Renderer Implementation
	Task: Hierarchical Level of Details Implementation

**Week 5 (11.27 - 12.3)**

	Task: Interaction GUI Implementation
	Task: Parallelize QuadTree

**Week 6 (12.4 - 12.10)**
	Task: Further Optimizations
	Task: Experiments
