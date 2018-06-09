''''''
import PID as pid
import time
import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import interp1d
import random as rn
import math
class disel:
    def __init__(self, P, I, D,sampletime,point=1):
        self.disel = pid.PID(P, I, D)
        self.sumpoint=point
        self.disel.setSampleTime(sampletime)
        self.disel.SetPoint = self.sumpoint
        self.feedback_disel_list = []
        self.setpoint_disel_list = []
        self.disel_feedback = 1

    def a(self):
        return 0

class Pe2h:
    def __init__(self, P=0.5,I=2,D=0,sampletime=1,point=1):
        self.pe2h = pid.PID(P, I, D)
        self.pe2h.setSampleTime(sampletime)
        self.pe2h.SetPoint = point
        self.pe2h_feedback=0
        self.spill=False
        self.max=30


    def pe2b_spill(self, rtemp):
        if rtemp >self.max:
            self.spill=True
        else:
            self.spill=False
        return self.spill

class wind:
    def __init__(self):
        self.data=[]
    def read(self):
        return 0

class  sun:
    def _init_(self):
        self.data=[]
    def read(self):
        return 0

class therm:
    def __init__(self, cost_rate=0):
        self.temp=20
        self.cost_rate=cost_rate
        self.cost=0
    def clear(self):
        self.cost=0
        return self.cost
    def leak(self):
        #self.cost += (self.temp-20)
        self.temp=(self.temp-20)*(1-self.cost_rate)+20

class system:
    def __init__(self,flag=1):
       self.time_list = []
       self.timesum = 1000
       self.output =0
       self.output_list=[]
       self.disel_list=[]
       self.disel_index=0
       self.pe2b=0
       self.fake_list=[]
       self.fake=0
       self.flag=flag
       self.pe2h= Pe2h()
       self.wind=wind()
       self.sun=sun()
       self.therm=therm()
       self.capacity=0

    def disel_init(self,P=0.5, I=2, D=0,sampletime=1,point=1):
        self.disel_list.append(disel(P, I, D,sampletime,point))
        self.disel_index+=1
        return self.disel_list[self.disel_index-1]

    def Pe2b(self,i):
        self.capacity+= self.pe2b
        if self.disel_list[i].disel.isfull() :
            if self.disel_list[i].disel_feedback>self.disel_list[i].sumpoint:
                self.pe2b = self.pe2b-0.02
            elif self.disel_list[i].disel_feedback<self.disel_list[i].sumpoint:
                self.pe2b = self.pe2b+0.02
        if (self.capacity>100 and self.pe2b>0) : self.pe2b=0
        if self.capacity<0:
            self.capacity=0
            self.pe2b=0
        if self.pe2b>0.8: self.pe2b=0.8
        if self.pe2b<-0.8: self.pe2b = -0.8
        #if self.capacity>0: print self.capacity
        return self.pe2b


    def e2h(self):
        if (self.pe2b>0 or self.capacity>10) and self.pe2h.pe2b_spill(self.therm.temp):
            self.therm.temp+=0.02
            return self.pe2b
        else:
            return 0

    def run(self):

        for i in range(1, self.timesum):
           # rnlist[i-1] +=  0
            #self.disel_list[0].disel.SetPoint=self.disel_list[0].sumpoint-self.pe2b * self.flag
            self.disel_list[0].disel.update(self.disel_list[0].disel_feedback)
            self.output = self.disel_list[0].disel.output
            self.Pe2b(0)
            self.disel_list[0].disel_feedback += rnlist[i - 1]
            self.disel_list[0].disel_feedback += self.output+((self.pe2b+self.e2h()) * self.flag)
            self.therm.leak( )
            #if self.flag==1 and self.pe2b!=0 : print self.pe2b
            self.output_list.append(self.output)
            self.disel_list[0].feedback_disel_list.append(self.disel_list[0].disel_feedback+self.flag*2)
            self.disel_list[0].setpoint_disel_list.append(self.disel_list[0].disel.SetPoint)
            self.time_list.append(i)



time_start=time.time()


rnlist = []
tmp = 0
rnlist_smooth=[]
for i in range(1, 1000):
    rnlist_smooth.append(math.sin(i/30.0)*0.8)

    if i % 20 == 0:
        tmp = rn.uniform(-0.8, 0.8)
        rnlist.append(tmp)
    else:
        rnlist.append(tmp)



test= system(1)
test.disel_init()
test.run()
test2= system(0)
test2.disel_init()
test2.run()
time_end=time.time()
print time_end-time_start
plt.plot(test.time_list, test.disel_list[0].feedback_disel_list)
plt.plot(test2.time_list, test2.disel_list[0].feedback_disel_list)
plt.plot(test.time_list, rnlist)
plt.xlim((0, test.timesum))
plt.ylim((-1, 4))
plt.xlabel('time (s)')
plt.ylabel('PID (PV)')
plt.title('TEST PID')
plt.grid(True)
plt.show()

'''
    #time_sm = np.array(time_list)
    #time_smooth = np.linspace(time_sm.min(), time_sm.max(), 1000)
    #feedback_smooth = spline(time_list, feedback_list, time_smooth)

    #plt.plot(time_smooth, feedback_smooth)
    plt.plot(time_list, feedback_list)
    plt.plot(time_list, setpoint_list)
    plt.plot(time_list, rnlist)
    plt.xlim((0, L))
    #plt.ylim((min(feedback_list) - 0.5, max(feedback_list) + 0.5))
    plt.ylim((-2, 2))
    plt.xlabel('time (s)')
    plt.ylabel('PID (PV)')
    plt.title('TEST PID')
    #plt.ylim((1 - 0.5, 1 + 0.5))

    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    disel(1.2, 1, 0.001, L=10000)
'''
