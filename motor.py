
import numpy as np
import math 

class SM:
    """docstring for ClassName"""
    def __init__(self,sampletime=0.01):
        self.sampletime= sampletime
        self.Vref=1
        self.Vab=1
        self.Vbc=-math.sqrt(3)/2
        self.Vabpu=1+0j
        self.Vbcpu=0.5j-math.sqrt(3)/2
        self.Vdq=0+0j
        self.Vdq2=0+0j
        self.I2=1+0j
        self.L2=1
        self.Vq=0
        self.Vd=0
        #self.theta_e=0
        #self.theta_web=0
        #self.theta_int=0
        self.theta_diff=0
        self.n=3
        self.nstate=5
        self.vcm=np.ones((self.nstate,1))
        self.W=np.zeros((self.nstate,self.nstate))
        self.we=1
        self.phi=np.ones((self.nstate,1))
        '''
        self.sat=1
        self.nselectphi=1
        self.Laq=0
        self.Lad=0
        self.phimq=0
        self.phimd=np.zeros(3)
        self.LIq=1
        self.LI=1
        self.LIfd=1
        self.LIkd=1
        self.Te=0
        self.Ifqsat=0
        self.Lmq=1
        self.Lmd=1
        '''
    
        self.IqdSign=np.array([[-1],[-1],[1],[1],[1]])
        self.Linv=np.array([[4.1,0,0,0,-3.05],[0,4.0,-2.23,-1.43,0],[0,-2.23,4.0,-1.45,0],[0,-1.43,-1,3.07,0],[-3.05,0,0,0,-3]])
        self.I=0
        self.P=0
        self.Q=0
        self.k=1
        self.m=0.1
        self.error1=0
        self.error2=0

    def update(self):
        self.Vabpu= self.Vab/self.Vref
        self.Vbvpu= self.Vbc/self.Vref
        #self.theta_int += self.theta_web * self.sampletime
        #self.theta_diff=self.theta_e- self.theta_e
        self.em_dq()
        self.em_cm()
        self.P=self.Vd*self.Id+self.Vq*self.Iq
        self.Q=self.Vq*self.Id-self.Vd*self.Iq
        self.Te=self.k*self.P/(self.we/50)
        self.Tp=1
        #self.fuzzy()
        #self.we += (self.Tp-self.Te)*self.m

    def em_dq(self):
        #self.Vdq=self.Vabpu/3-self.Vbcpu/3*(math.exp(-(1j)*2*math.pi/3)) #* (math.exp(-(1j)*self.theta_diff))
        self.Vdq=self.Vabpu/3-self.Vbcpu/3*(math.sin(-2*math.pi/3)*(1j)+math.cos(2*math.pi/3))
        self.Vd = self.Vdq.imag
        self.Vq = self.Vdq.real
        '''
        V=RI+L*dI/dt
        dI/dt=-(R/L)*I+V/L
        in dq:
        dId/dt=-(r/l)*Id+Iq+Vd/L
        dIq/dt=-(r/l)*Iq-Id+Vq/L
        '''
        #self.Vdq2=(self.Vabpu/3-self.Vbcpu/3*math.exp(-(1j)*math.pi/3)) 
        #self.I2 += (complex(self.I2.imag-self.I2.real)-self.I2/30-self.Vdq2/self.L2)#*self.theta_web

    
    def em_cm(self):
        self.vcm[0,0]= self.Vq
        self.vcm[1,0]= self.Vd
        self.vcm[2,0]=self.Vref*self.n
        self.W[0,1]=self.we
        self.W[1,0]=-self.we
        #self.W += self.xxx
        self.phi += (self.vcm-np.dot(self.W,self.phi))*self.sampletime#*self.theta_web
        #self.phimq+=self.phi[0,self.nselectphi]/self.LIq*self.Laq
        #self.phimd+=self.phi[1,1:4]/np.array([self.LI,self.LIfd,self.LIkd])*self.Lad
        #self.em_cm_sat()
        for i in range(5):
            self.phi[i,0] += (1-self.phi[i,0])*1.1

        self.I=np.dot(self.Linv,self.phi)*self.IqdSign
        self.Id=self.I[0]
        self.Iq=self.I[1]
        #self.Te += self.phi[0,[1,0]]*self.I[0:2]
        #self.Lmqd=np.arrary([self.Lmq,self.Lmd])
     
a=SM()

for i in range(10):
    a.update()
    print a.P

        


    

         
