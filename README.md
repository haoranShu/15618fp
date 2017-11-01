# 15618fp

- Summary
	We are going to implement a Parallel Iteractive Visualization of Heatmap on Large Datasets on Web Browsers, using a Shared Nothing Architecture like Latedays with a Message Passing Paradigm.

- Background
	Recently scientists' ability to collect and process large datasets have been growing rapidly, marking an increasing need for effective and efficient visualization tools on large datasets. Visualization of large datasets differs greatly from traditional visualization in many aspects, apart from their obvious difference in size. For point set visualization, for example, point occlusion makes it hard to generate effective and honest presentation of a million-level dataset in a laptop screen. Also, interactive visualization may require re-computation on each level of detail. Sometimes, it is even hard to load the whole dataset into memory, when we have to resort to distributed clusters. All these factors make visualization on large datasets a topic of interest and a great objective for parallel computing.

	Among various visualization problems on large datasets, we chose to work on the Interactive Visualization of Heatmaps because of both the its popularity, as a method to represent big data, among different kinds of datasets, and its well-definedness to guide our project.

	More formally, a heatmap is a continuous representation of discrete point sets. It takes advantage of function estimation techniques to generate a density function of the input data and map it to a predefined color scheme. It is widely used to represent data pertaining to geographic distribution of information, providing easy-to-read plots. Its easy-to-read property also makes it much more popular than other general visualization paradigms among non-scientist users on the Web, thus we planed to deliver an implementation on Web Browsers specifically.

- The Challenge
	1. Size of Data:
		The size of input data is the primary motivation for our project. Most of the time, the available dataset cannot be loaded into the memory of a single commodity machine and needs to be distributedly stored and processed. Although we might use downsized datasets in our projects, we are going to implement our algorithm with a Message Passing Paradigm to simulate this reality.

	2. Data Occlusion:
		Data Occlusion happens when the amount of data is much larger than the amount of usable pixels in our screen (or human eyes) so that it is hard to differentiate beween dense areas of the visualization, where huge differences might actually exist. It is at the core of providing "effective" visualizations and suitable pre-processing and sampling of datasets must be carried out. Coming with this need are limitations in our design of the algorithm because of the potential synchronization and communication it might require.

	3. Consistency Requirement:
		Processing different portion of input data on different machines introduces the problem of non-consistency in the resulting visualizations. How to reconcile the discrepancies on border of plot blocks becomes a problem and might require additional synchronization and communication, which may increase the latency of our algorithm.

	4. Interactive Visualization:
		It is necessary to provide an interactive interface for users so that they can scrutinize the data at different levels. This is typically enabled by computing corresponding visualizations of different levels of detail and provide most suitable version to users statically. It would save a lot of computation and offer better results if we can compute on the fly dynamically, on the basis of some rawly pre-computed results, but this strategy requires faster communication.

