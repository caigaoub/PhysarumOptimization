import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
import math
import warnings


def physarum_solver(G_, size_, source_, sink_, log):
	if source_ == sink_:
		warnings.filterwarnings(" *** Error: source is same as sink!! ***")
				
	""" -->> Initialization <<--  """
	conduc_matrix = np.ones([size_,size_])
	np.fill_diagonal(conduc_matrix, 0)
	dist_matrix = nx.to_numpy_matrix(G_)
	dist_matrix[dist_matrix == 0] = math.inf
	cur_gap = math.inf
	threshold = 1e-5
	iterations = 0

	""" -->> Physarum Evolution Iterations <<-- """
	while cur_gap > threshold:
		coef_matrix = np.true_divide(conduc_matrix,dist_matrix)
		for i in range(0,size_):
			coef_matrix[i,i]= -np.sum(coef_matrix[i,:],dtype = np.float32)
		idx = []
		if sink_ != 0 and sink_ != size_ - 1:
			idx = np.r_[0:sink_, sink_+1:size_]
		else:
			if sink_ == 0:
				idx = np.r_[1:size_]
			if sink_ == size_ - 1:
				idx = np.r_[0:size_-1]

		b = np.zeros([size_ - 1, 1])
		if sink_ < source_:
			b[source_ - 1] = -1
		else:
			b[source_] = -1

		pres_vector = np.linalg.solve(coef_matrix[np.ix_(idx,idx)],b)
		new_pres_vector = np.insert(pres_vector, sink_, 0)
		pres_matrix = np.tile(new_pres_vector.transpose(),(size_,1))
		flow_matrix = np.multiply((np.transpose(pres_matrix) - pres_matrix), coef_matrix)
		if log:
			np.set_printoptions(precision=3,suppress=True)
			print(flow_matrix)
			print("==================================")
		old_conduc_matrix = conduc_matrix
		conduc_matrix = 0.5 * (np.absolute(flow_matrix)+conduc_matrix)
		# conduc_matrix[conduc_matrix<threshold] = 0
		cur_gap = np.sum(np.absolute(old_conduc_matrix - conduc_matrix))

		iterations += 1
		""" If current path is not feasible, add penalty to every edge """
		
		

		# if iterations > 100:
		# 	break

#####################################################
G = nx.Graph()
V = list(range(1,6))
G.add_nodes_from(V)
E = [(1,2,4),(1,3,1),(2,3,1),(2,4,3),(2,5,3),(3,4,2),(4,5,2)]
G.add_weighted_edges_from(E)
log_on = True
physarum_solver(G, len(G.nodes), 4, 0, log_on)