import numpy as np
import networkx as nx
import matplotlib.pyplot as plt


if __name__ == "__main__":
	""" Generate a simple graph """
	G = nx.Graph()
	for i in range(0,5):
		G.add_node(i)
	G.add_edge(0,1,weight=1)
	G.add_edge(0,2,weight=1)
	G.add_edge(0,3,weight=1)
	G.add_edge(0,4,weight=1)
	G.add_edge(1,2,weight=2)
	G.add_edge(2,3,weight=2)
	G.add_edge(3,4,weight=2)
	G.add_edge(4,1,weight=2)



	s0 = 1
	s1 = 1
	s2 = 1
	s3 = 1
	s4 = 1
	# if si + sj > 0.5, fire; otherwise, not fire