import numpy as np

def ReLU(x):
    y = np.maximum(0, x).astype(int)
    return y

def Abs(x):
    y = np.absolute(x).astype(int)
    return y

def Theta(x):
    y = np.heaviside(x, 0).astype(int)
    return y

def ListAdd(in1, in2):
    wrk = np.array(in1) + np.array(in2)
    return wrk.tolist()
