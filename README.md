# 15618fp

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

* We are planning to start this project from scratch as this will allow us to explore different options and choose our platform and technologies more freely. However, since we are planning to implement visualization on web browsers, there might be some existing web frameworks that we will need to look into to expedite the development process and focus on the potential parallelism of our implementation.

* Reference: Research on Heatmap for Big Data Based on Spark, Zhang Fan, Yuan Zhaokang, Xiao Fanping, You Kun, Wang Zhangye, Journal of Computer-Aided Design & Computer Graphics. Vol. 28, No. 11, November 2016.

* One of the most important resource that we need is the dataset for the heatmap. We have yet to figure out the type of data to visualize and also where we can find them. As mentioned before, we plan to find a dataset that is hard to fit in any single commodity machine, and therefore, requires parallel processing in a distributed fashion.

* The processing of the big dataset will mostly be based on Apache Spark and the actual visualization will be implemented in the web browser. Therefore, we do not need any special machines in our implementation.

## Goals and Deliverables

### Plan to achieve

1. Come up with a way to separate the dataset into different tiles of different resolutions to allow parallel processing and interactive manipulation of the heatmap.

1. Parallel process of the data on Apache Spark of the tiles, and store the results on HDFS.

1. Use the processed data from HDFS, generate a heatmap visualization using WebGL JavaScript Library.

### Hope to achieve

1. Instead of using a single dataset and HDFS as an intermediate storage, use Spark Streaming to process the incoming data stream and display the heatmap in real time to the users.

### Demo

We plan to demo our web application that displays a heatmap representation of our dataset and allows the user to zoom in and out and manipulate the time of interest. We will show the size of our dataset and the computation required for the interactive demo. We might also show the speed up graph of generating the heatmap using Apache Spark and WebGL.

## Platform of Choice

### Data Processing

We plan to use Apache Spark for this part of the project as it provides a convenient and fast way of processing large scale data. We need Apache Spark as the size of the data set is too large to fit in any single machine and demands too much computational resource to generate the heatmap.

### Data Visualization

We plan to use WebGL JavaScript Library for this part of the project as it provides API for rendering **interactive** 3D and 2D graphics that fit our needs. 

## Schedule

We divide our work into three phases.

1. **Phase I: 11.1 - 11.8** Preparations on datasets, paper reading and API studying.

2. **Phase II: 11.9 - 11.20** Core Implementation of Spark, including data pre-computation, kernel density estimation and tile aggregation.

3. **Phase III: 11.21 - 12.10** Application development and Algorithm Optimization, when we plan to optimize our algorithm and put it into use to visualize datasets on the web.
