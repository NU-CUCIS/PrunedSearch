# Copyright (C) 2016, Northwestern University
# See COPYRIGHT notice in top-level directory.

'''
MURI Feature Selection and Feature Ranges Computation through a Decision Tree
Author: Rosanne Liu
'''
import os, sys
import numpy as np
import scipy
#from IPython import embed
import pdb
import warnings
import argparse
import time
from sklearn.datasets import load_iris
from sklearn.feature_selection import SelectKBest
try:
    from sklearn.feature_selection import chi2, f_classif, mutual_info_classif, SelectPercentile, SelectFpr, SelectFwe
except:
    print 'You are using older version of sklearn, using chi2 for feature selection.'
    from sklearn.feature_selection import chi2 
from sklearn import tree

warnings.filterwarnings('ignore')


def gen_random_data(in_shape=(20,5)):
    '''Generate random data_x and data_y for unit test'''
    return np.random.normal(0,1, in_shape), np.sign(np.random.normal(0,1,(in_shape[0],)))

def get_example_data():
    iris = load_iris()
    target = iris.target
    return iris.data, target

def feature_selection(data_x, data_y, score_func=chi2):
    '''
    Rank features in data_x according to the target data_y and score function.
    
    This function is used as the 1st step of algorithm pipeline.

    Input
    --------
    data_x: np.array, (n_samples, n_features)
    
    data_y: np.array, (n_samples, )
    
    score_func: string, name of the score function you want to use. Support 
        
        - f_classif: ANOVA F-value between label/feature for classification tasks.
        
        - mutual_info_classif: Mutual information for a discrete target.
        
        - chi2: Chi-squared stats of non-negative features for classification tasks.
        
        - SelectPercentile: Select features based on percentile of the highest scores.
        
        - SelectFpr: Select features based on a false positive rate test.
        
        - SelectFwe: Select features based on family-wise error rate.

    Return
    --------
    scores: np.array, (n_features,), the scores for each feature
    sorted_feature_ids: np.array, (n_features,), the feature ids from import features to unimportant features. 
    '''
    n_samples, n_features = data_x.shape
    
    model = SelectKBest(score_func,k = n_features)
    model.fit(data_x, data_y)

    return model.scores_, np.argsort(model.scores_)[::-1]


###############################
## Tree Structure Traverse   ##
###############################
def get_parent(node_id, left, right):
    '''
    Return the node_id of parent and size given tree node structure.

    Input
    --------
    node_id: int, current node id

    left: np.array, left child structure

    right: np.array, right child structure

    Output
    --------
    parent_id: int, the node id of current node parent.

    node_side: bool, 'True'-> current node is left child; 'False'-> current node is right child
    '''
    node_side = None
    parent_id = None
    left_ids = np.where(left == node_id)[0]
    right_ids = np.where(right == node_id)[0]
    if len(left_ids) > 0:
        node_side = True
        parent_id = left_ids.item()
    elif len(right_ids) > 0:
        node_side = False
        parent_id = right_ids.item()
    else:
        raise ValueError('node %d does not have any parent'%node_id)

    return parent_id, node_side

def mark_features_by_leaf(tree, records, leaf_node_id):
    '''
    Mark related features starting from a given leaf node

    Input
    --------
    tree: sklearn.tree.DecisionTreeClassifier, trained decision tree

    records: dictionary, {key: feature_id -> value: [sides_list, threshold]}, this can be empty in the begining.

    leaf_node_id: int, the leaf node 

    Output
    --------
    records: dictionary, the modified record
    '''
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    feature = tree.tree_.feature
    threshold = tree.tree_.threshold

    node_id = leaf_node_id
    while node_id != 0:
        parent_node_id, node_side = get_parent(node_id, left, right)
        parent_node_feature_id = feature[parent_node_id]
        parent_node_threshold = threshold[parent_node_id]

        if parent_node_feature_id in records.keys():
            v = records[parent_node_feature_id]
            v[0].append(node_side)
        else:
            records[parent_node_feature_id] = [[node_side], parent_node_threshold]
        node_id = parent_node_id
            
    return records


def calc_feature_ranges(data_x, data_y):
    '''
    Compute the optimization range for each feature.
    
    This function build a decision classification tree, then exam each tree node,
      the node split threshold leads to positive label is the optimization range.

    Input
    --------
    
    data_x: np.array, (n_samples, n_features)
    
    data_y: np.array, (n_samples, )

    Return 
    --------
    
    feature_ranges: dictionary, <feature_id, [low bound, high bound]>
    '''
    select_class = 1
    clf = tree.DecisionTreeClassifier(criterion='gini', max_depth=None,
                                      min_samples_split=2, min_samples_leaf=1,
                                      max_features=None)
    clf.fit(data_x, data_y)
    
    value = clf.tree_.value
    leaf_node_ids = np.argwhere(clf.tree_.children_left == -1)[:,0]
    valid_leaf_node_ids = []
    records = {}
    for leaf_node in leaf_node_ids:
        if np.argmax(value[leaf_node,0,:]) == select_class:
            valid_leaf_node_ids.append(leaf_node)
            records = mark_features_by_leaf(clf, records, leaf_node)

    # parse records to feature ranges
    feature_ranges = []
    for f_id in range(data_x.shape[1]):
        min_ = np.min(data_x[:,f_id])
        max_ = np.max(data_x[:,f_id])
        if f_id in records.keys():
            v = records[f_id]
            if np.sum(v[0]) == 0: # all False -> all right side
                min_ = v[1]
            elif np.sum(v[0]) == len(v[0]): # all True -> all left side
                max_ = v[1]
        feature_ranges.append([min_, max_])
    return np.vstack(feature_ranges)


def unit_test():
    iris = load_iris()
    X = iris.data
    y = iris.target
    from sklearn.model_selection import train_test_split
    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=0)
    calc_feature_thresholds(X_train, y_train)

def load_data(datafn):
    with open('data/data_demo.mat','r') as f:
        dd = scipy.io.loadmat(f)
    data = dd['dataPolar']
    N = len(data)
    data[:N/2,-1] = 0
    data[N/2:,-1] = 1
    data_x = data[:,:-1]
    data_y = data[:,-1]
    #with open(datafn, 'r') as f:
    #    data = np.loadtxt(f, delimiter=',')
    #    data_x = data[:,:-1]
    #    data_y = data[:,-1]
    return data_x, data_y

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Train Feature Range Model', formatter_class=lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog))
    parser.add_argument('--input_data',type=str, default='../data/data_demo.mat', help='input data file name')
    parser.add_argument('--output_data',type=str, default='../model_output/demo_modelout.mat', help='output file name')
    parser.add_argument('--ipy',action='store_true',  help='debugging mode, drop into ipython')
    args = parser.parse_args()
    
    # You can also use pandas to read data if you want.
    #import pandas as pd
    #data = pd.read_csv(args.input_data,delimiter=',')
    #data_y = data['class'].as_matrix()
    #data = data.drop(['class'],1)
    #data_x = data.as_matrix()
    
    # otherwise, just use numpy
    data_x, data_y = load_data(args.input_data)
    print 'Feature selection ',
    st = time.time()
    feature_scores, sorted_feature_ids = feature_selection(data_x, data_y)
    print ' cost %.4f seconds'%(time.time() - st)
    print 'Fitting the decision tree and compute feature range ',
    st = time.time()
    feature_ranges = calc_feature_ranges(data_x, data_y)
    print ' cost %.4f seconds'%(time.time() - st)
    
    with open(args.output_data, 'w') as f:
        scipy.io.savemat(f, {'sorted_feature_ids':sorted_feature_ids, 'feature_ranges':feature_ranges})
    
    if args.ipy:
        with open(args.output_data,'r') as f:
            dd = scipy.io.loadmat(f)
	pdb.set_trace()
        #embed()
