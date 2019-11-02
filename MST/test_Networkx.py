import numpy as np
import networkx as nx
import matplotlib.pyplot as plt



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
print("networkx package testing ")
print("nodes: ", G.nodes) # or print(nx.nodes(G))
print("edges: ", G.edges) 
print("access edge attr M1: ", G[1][2]['weight'])
print("access edge attr M2: ", G.edges[1,2]['weight'])
print("Adjacent list: ", G.adj) # alll adjacent list
print("Node neighbors: ", G.adj[1])
print("access dict")
for x in G.adj[1]:
	# print(x)
	print(G.adj[1][x]['weight'])