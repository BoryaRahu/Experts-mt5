/// \file
/// \brief NeuroNet.cl
/// Library consist OpenCL kernels
/// \author <A HREF="https://www.mql5.com/en/users/dng"> DNG </A>
/// \copyright Copyright 2019, DNG
//---
//--- by default some GPU doesn't support doubles
//--- cl_khr_fp64 directive is used to enable work with doubles
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
/// Max weight in matrix
#define MAX_WEIGHT 1000.0
/// Value of max gradient
#define MAX_GRADIENT 1.0
//+------------------------------------------------------------------+
///\ingroup neuron_base_ff Feed forward process kernel
/// Describes the forward path process for the Neuron Base (#CNeuronBaseOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para41">the link.</A>
//+------------------------------------------------------------------+
__kernel void FeedForward(__global double *matrix_w,///<[in] Weights matrix (m+1)*n, where m - number of neurons in layer and n - number of outputs (neurons in next layer)
                          __global double *matrix_i,///<[in] Inputs tesor
                          __global double *matrix_o,///<[out] Output tensor
                          int inputs,///< Number of inputs
                          int activation///< Activation type (#ENUM_ACTIVATION)
                          )
  {
   int i=get_global_id(0);
   double sum=0.0;
   double4 inp, weight;
   int shift=(inputs+1)*i;
   for(int k=0; k<=inputs; k=k+4)
     {
      switch(inputs-k)
        {
         case 0:
           inp=(double4)(1,0,0,0);
           weight=(double4)(matrix_w[shift+k],0,0,0);
           break;
         case 1:
           inp=(double4)(matrix_i[k],1,0,0);
           weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],0,0);
           break;
         case 2:
           inp=(double4)(matrix_i[k],matrix_i[k+1],1,0);
           weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],matrix_w[shift+k+2],0);
           break;
         case 3:
           inp=(double4)(matrix_i[k],matrix_i[k+1],matrix_i[k+2],1);
           weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],matrix_w[shift+k+2],matrix_w[shift+k+3]);
           break;
         default:
           inp=(double4)(matrix_i[k],matrix_i[k+1],matrix_i[k+2],matrix_i[k+3]);
           weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],matrix_w[shift+k+2],matrix_w[shift+k+3]);
           break;
        }
      double d=dot(inp,weight);
      if(isnan(sum+d))
         continue;
      sum+=d;
     }
   if(isnan(sum))
      sum=0;
   switch(activation)
     {
      case 0:
        sum=tanh(clamp(sum,-20.0,20.0));
        break;
      case 1:
        sum=1/(1+exp(-clamp(sum,-20.0,20.0)));
        break;
      case 2:
        if(sum<0)
           sum*=0.01;
        break;
      default:
        break;
     }
   matrix_o[i]=sum;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_base_gr  Neuron Base Output Gradients Calculation kernel
/// Describes the process of output gradients calculation for the Neuron Base (#CNeuronBaseOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para42">the link.</A>
//+------------------------------------------------------------------+
__kernel void CalcOutputGradient(__global double *matrix_t,///<[in] Target tensor
                                 __global double *matrix_o,///<[in] Output tensor
                                 __global double *matrix_ig,///<[out] Tensor of gradients
                                 int activation///< Activation type (#ENUM_ACTIVATION)
                                 )
  {
   int i=get_global_id(0);
   double temp=0;
   double out=matrix_o[i];
   switch(activation)
     {
      case 0:
        temp=clamp(matrix_t[i],-1.0,1.0)-out;
        temp=temp*(1-pow(out==1 || out==-1 ? 0.99999999 : out,2));
        break;
      case 1:
        temp=clamp(matrix_t[i],0.0,1.0)-out;
        temp=temp*(out==0 || out==1 ? 0.00000001 : (out*(1-out)));
        break;
      case 2:
        temp=(matrix_t[i]-out)*(out>=0 ? 1.0 : 0.01);
        break;
      default:
        temp=(matrix_t[i]-out);
        break;
     }
   matrix_ig[i]=clamp(temp,-MAX_GRADIENT,MAX_GRADIENT);
  }
//+------------------------------------------------------------------+
///\ingroup neuron_base_gr  Neuron Base Hidden Gradients Calculation kernel
/// Describes the process of hidden gradients calculation for the Neuron Base (#CNeuronBaseOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para42">the link.</A>
//+------------------------------------------------------------------+
__kernel void CalcHiddenGradient(__global double *matrix_w,///<[in] Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
                                 __global double *matrix_g,///<[in] Tensor of gradients at current layer
                                 __global double *matrix_o,///<[in] Previous layer Output tensor
                                 __global double *matrix_ig,///<[out] Tensor of gradients at previous layer
                                 int outputs,///< Number of outputs
                                 int activation///< Activation type (#ENUM_ACTIVATION)
                                 )
  {
   int i=get_global_id(0);
   int inputs=get_global_size(0);
   double sum=0;
   double out=matrix_o[i];
   double4 grad, weight;
   for(int k=0;k<outputs;k+=4)
     {
      switch(outputs-k)
        {
         case 1:
           grad=(double4)(matrix_g[k],0,0,0);
           weight=(double4)(matrix_w[k*inputs+i],0,0,0);
           break;
         case 2:
           grad=(double4)(matrix_g[k],matrix_g[k+1],0,0);
           weight=(double4)(matrix_w[k*inputs+i],matrix_w[k*inputs+i+1],0,0);
           break;
         case 3:
           grad=(double4)(matrix_g[k],matrix_g[k+1],matrix_g[k+2],0);
           weight=(double4)(matrix_w[k*inputs+i],matrix_w[k*inputs+i+1],matrix_w[k*inputs+i+2],0);
           break;
         default:
           grad=(double4)(matrix_g[k],matrix_g[k+1],matrix_g[k+2],matrix_g[k+3]);
           weight=(double4)(matrix_w[k*inputs+i],matrix_w[k*inputs+i+1],matrix_w[k*inputs+i+2],matrix_w[k*inputs+i+3]);
           break;
        }
      sum+=dot(grad,weight);
     }
   if(isnan(sum))
      sum=0;
   switch(activation)
     {
      case 0:
        sum=clamp(sum+out,-0.99,0.99)-out;
        sum=sum*(1-pow(out==1 || out==-1 ? 0.99999999 : out,2));
        break;
      case 1:
        sum=clamp(sum+out,0.01,0.99)-out;
        sum=sum*(out==0 || out==1 ? 0.00000001 : (out*(1-out)));
        break;
      case 2:
        if(out<0)
           sum*=0.01;
        break;
      default:
        break;
     }
   matrix_ig[i]=clamp(sum,-MAX_GRADIENT,MAX_GRADIENT);
  }
//+------------------------------------------------------------------+
///\ingroup neuron_base_opt  Neuron Base SGD Updating Weights Calculation kernel
/// Describes the process of SGD optimization weights for the Neuron Base (#CNeuronBaseOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para43">the link.</A>
//+------------------------------------------------------------------+
__kernel void UpdateWeightsMomentum(__global double *matrix_w, ///<[in,out] Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
                            __global double *matrix_g,         ///<[in] Tensor of gradients at current layer
                            __global double *matrix_i,         ///<[in] Inputs tesor
                            __global double *matrix_dw,        ///<[in,out] Matrix of delta weights in last correction
                            int inputs,                        ///< Number of inputs
                            double learning_rates,             ///< Learning rates
                            double momentum                    ///< Momentum multiplier
                            )
  {
   int i=get_global_id(0);
   int j=get_global_id(1);
   int wi=i*(inputs+1)+j; 
   double delta=learning_rates*matrix_g[i]*(j<inputs ? matrix_i[j] : 1) + momentum*matrix_dw[wi];
   if(!isnan(delta))
     {
      matrix_dw[wi]=delta;
      matrix_w[wi]=clamp(matrix_w[wi]+delta,-MAX_WEIGHT,MAX_WEIGHT);
     }
  };
//+------------------------------------------------------------------+
///\ingroup neuron_base_opt  Neuron Base Adam Updating Weights Calculation kernel
/// Describes the process of Adam optimization weights for the Neuron Base (#CNeuronBaseOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8598#para31">the link.</A>
//+------------------------------------------------------------------+
__kernel void UpdateWeightsAdam(__global double *matrix_w,        ///<[in,out] Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
                                __global const double *matrix_g,  ///<[in] Tensor of gradients at current layer
                                __global const double *matrix_i,  ///<[in] Inputs tesor
                                __global double *matrix_m,        ///<[in,out] Matrix of first momentum
                                __global double *matrix_v,        ///<[in,out] Matrix of seconfd momentum
                                const int inputs,                 ///< Number of inputs
                                const double l,                   ///< Learning rates
                                const double b1,                  ///< First momentum multiplier
                                const double b2                   ///< Second momentum multiplier
                                )
  {
   const int i=get_global_id(0);
   const int j=get_global_id(1);
   const int wi=i*(inputs+1)+j*4;
   double4 m, v, weight, inp;
   switch(inputs+1-j*4)
     {
      case 0:
        inp=(double4)(1,0,0,0);
        weight=(double4)(matrix_w[wi],0,0,0);
        m=(double4)(matrix_m[wi],0,0,0);
        v=(double4)(matrix_v[wi],0,0,0);
        break;
      case 1:
        inp=(double4)(matrix_i[j],1,0,0);
        weight=(double4)(matrix_w[wi],matrix_w[wi+1],0,0);
        m=(double4)(matrix_m[wi],matrix_m[wi+1],0,0);
        v=(double4)(matrix_v[wi],matrix_v[wi+1],0,0);
        break;
      case 2:
        inp=(double4)(matrix_i[j],matrix_i[j+1],1,0);
        weight=(double4)(matrix_w[wi],matrix_w[wi+1],matrix_w[wi+2],0);
        m=(double4)(matrix_m[wi],matrix_m[wi+1],matrix_m[wi+2],0);
        v=(double4)(matrix_v[wi],matrix_v[wi+1],matrix_v[wi+2],0);
        break;
      case 3:
        inp=(double4)(matrix_i[j],matrix_i[j+1],matrix_i[j+2],1);
        weight=(double4)(matrix_w[wi],matrix_w[wi+1],matrix_w[wi+2],matrix_w[wi+3]);
        m=(double4)(matrix_m[wi],matrix_m[wi+1],matrix_m[wi+2],matrix_m[wi+3]);
        v=(double4)(matrix_v[wi],matrix_v[wi+1],matrix_v[wi+2],matrix_v[wi+3]);
        break;
      default:
        inp=(double4)(matrix_i[j],matrix_i[j+1],matrix_i[j+2],matrix_i[j+3]);
        weight=(double4)(matrix_w[wi],matrix_w[wi+1],matrix_w[wi+2],matrix_w[wi+3]);
        m=(double4)(matrix_m[wi],matrix_m[wi+1],matrix_m[wi+2],matrix_m[wi+3]);
        v=(double4)(matrix_v[wi],matrix_v[wi+1],matrix_v[wi+2],matrix_v[wi+3]);
        break;
     }
   double4 g=(double4)(matrix_g[i])*inp;
   double4 mt=clamp(b1*m+(1-b1)*g,-1.0e5,1.0e5);
   double4 vt=clamp(b2*v+(1-b2)*pow(g,2),1.0e-6,1.0e6);
   double4 delta=l*mt/(vt>0  ? sqrt(vt) : l*10);
   switch(inputs+1-j*4)
     {
      case 2:
        matrix_w[wi+2]=clamp(matrix_w[wi+2]+delta.s2,-MAX_WEIGHT,MAX_WEIGHT);
        matrix_m[wi+2]=mt.s2;
        matrix_v[wi+2]=vt.s2;
      case 1:
        matrix_w[wi+1]=clamp(matrix_w[wi+1]+delta.s1,-MAX_WEIGHT,MAX_WEIGHT);
        matrix_m[wi+1]=mt.s1;
        matrix_v[wi+1]=vt.s1;
      case 0:
        matrix_w[wi]=clamp(matrix_w[wi]+delta.s0,-MAX_WEIGHT,MAX_WEIGHT);
        matrix_m[wi]=mt.s0;
        matrix_v[wi]=vt.s0;
        break;
      default:
        (double4)(matrix_w[wi],matrix_w[wi+1],matrix_w[wi+2],matrix_w[wi+3])=clamp((double4)(matrix_w[wi],matrix_w[wi+1],matrix_w[wi+2],matrix_w[wi+3])+delta,-MAX_WEIGHT,MAX_WEIGHT);
        (double4)(matrix_m[wi],matrix_m[wi+1],matrix_m[wi+2],matrix_m[wi+3])=mt;
        (double4)(matrix_v[wi],matrix_v[wi+1],matrix_v[wi+2],matrix_v[wi+3])=vt;
        break;
     }
  };
//+------------------------------------------------------------------+
///\ingroup neuron_proof_ff
/// Kernel of the Pooling neuron for Feed forward process (#CNeuronProofOCL)
//+------------------------------------------------------------------+
__kernel void FeedForwardProof(__global double *matrix_i,   ///<[in] Inputs tesor
                               __global double *matrix_o,   ///<[out] Output tensor
                              int inputs,                   ///< Number of inputs
                              int window,                   ///< Size of input window
                              int step                      ///< Step size
                              )
  {
   int i=get_global_id(0);
   int pos=i*step;
   double result=matrix_o[pos];
   for(int k=1; k<window; k=k+1)
     {
      int shift=k+pos;
      if(shift>=inputs)
         break;
      result=max(result,matrix_o[shift]);
     }
   matrix_o[i]=result;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_proof_gr
/// Kernel of the Pooling neuron to transfer gradient to previous layer (#CNeuronProofOCL)
//+------------------------------------------------------------------+
__kernel void CalcInputGradientProof(__global double *matrix_i,   ///<[in] Inputs tesor
                                      __global double *matrix_g,  ///<[in] Tensor of gradients at current layer
                                      __global double *matrix_o,  ///<[in] Output tensor
                                      __global double *matrix_ig, ///<[out] Tensor of gradients at previous layer
                                      int outputs,                ///< Number of outputs
                                      int window,                 ///< Size of input window
                                      int step                    ///< Step size
                                      )
  {
   int i=get_global_id(0);
   double prev_gradient=0;
   double value=matrix_i[i];
   int start=i-window+step;
   start=(start-start%step)/step;
   int stop=(i-i%step)/step+1;
   for(int out=max(0,start); out<min(outputs,stop); out++)
     {
      if(value==matrix_o[out])
         prev_gradient+=matrix_g[out];
     }
   matrix_ig[i]=prev_gradient;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_conv_ff
/// Kernel of the Convolution neuron for Feed forward process (#CNeuronConvOCL)
//+------------------------------------------------------------------+
__kernel void FeedForwardConv(__global double *matrix_w,             ///<[in] Weights matrix (m+1)*n, where m - input window and n - output window
                              __global double *matrix_i,             ///<[in] Inputs tesor
                              __global double *matrix_o,             ///<[out] Output tensor
                              int inputs,                            ///< Number of inputs
                              int step,                              ///< Step size
                              int window_in,                         ///< Size of input window
                              int window_out,                        ///< Size of output window
                              uint activation                        ///< Activation type (#ENUM_ACTIVATION)
                              )
  {
   int i=get_global_id(0);
   int w_in=window_in;
   int w_out=window_out;
   double sum=0.0;
   double4 inp, weight;
   int shift_out=w_out*i;
   int shift_in=step*i;
   for(int out=0;out<w_out;out++)
     {
      int shift=(w_in+1)*out;
      int stop=(w_in<=(inputs-shift_in) ? w_in : (inputs-shift_in));
      for(int k=0; k<=stop; k+=4)
        {
         switch(stop-k)
           {
            case 0:
              inp=(double4)(1,0,0,0);
              weight=(double4)(matrix_w[shift+k],0,0,0);
              break;
            case 1:
              inp=(double4)(matrix_i[shift_in+k],1,0,0);
              weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],0,0);
              break;
            case 2:
              inp=(double4)(matrix_i[shift_in+k],matrix_i[shift_in+k+1],1,0);
              weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],matrix_w[shift+k+2],0);
              break;
            case 3:
              inp=(double4)(matrix_i[shift_in+k],matrix_i[shift_in+k+1],matrix_i[shift_in+k+2],1);
              weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],matrix_w[shift+k+2],matrix_w[shift+k+3]);
              break;
            default:
              inp=(double4)(matrix_i[shift_in+k],matrix_i[shift_in+k+1],matrix_i[shift_in+k+2],matrix_i[shift_in+k+3]);
              weight=(double4)(matrix_w[shift+k],matrix_w[shift+k+1],matrix_w[shift+k+2],matrix_w[shift+k+3]);
              break;
           }
         sum+=dot(inp,weight);
        }
      if(isnan(sum))
         sum=0;
      switch(activation)
        {
         case 0:
           sum=tanh(sum);
           break;
         case 1:
           sum=1/(1+exp(-clamp(sum,-20.0,20.0)));
           break;
         case 2:
           if(sum<0)
              sum*=0.01;
           break;
         default:
           break;
        }
      matrix_o[out+shift_out]=sum;
     }
  }
//+------------------------------------------------------------------+
///\ingroup neuron_conv_gr
/// Kernel of the Convolution neuron to transfer gradient to previous layer (#CNeuronConvOCL)
//+------------------------------------------------------------------+
__kernel void CalcHiddenGradientConv(__global double *matrix_w,   ///<[in] Weights matrix (m+1)*n, where m - input window and n - output window
                                     __global double *matrix_g,   ///<[in] Tensor of gradients at current layer
                                    __global double *matrix_o,    ///<[in] Output tensor
                                    __global double *matrix_ig,   ///<[out] Tensor of gradients at previous layer
                                    int outputs,                  ///< Number of outputs
                                    int step,                     ///< Step size
                                    int window_in,                ///< Size of input window
                                    int window_out,               ///< Size of output window
                                    uint activation               ///< Activation type (#ENUM_ACTIVATION)
                                    )
  {
   int i=get_global_id(0);
   int inputs=get_global_size(0);
   double sum=0;
   double out=matrix_o[i];
   int start=i-window_in+step;
   start=(start-start%step)/step;
   int stop=(i-i%step)/step+1;
   if(stop>(outputs/window_out))
      stop=outputs;
   for(int h=0;h<window_out;h+=4)
     {
      for(int k=start;k<stop;k++)
        {
         int shift_w=(stop-k-1)*step+i%step+h*(window_in+1);
         int shift_g=k*window_out+h;
         if(shift_g>=outputs || shift_w>=(window_in+1)*window_out)
            break;
         sum+=matrix_g[k*window_out+h]*matrix_w[shift_w];
        }
     }
   if(isnan(sum))
      sum=0;
   switch(activation)
     {
      case 0:
        sum=clamp(sum+out,-1.0,1.0)-out;
        sum=sum*(1-pow(out==1 || out==-1 ? 0.99999999 : out,2));
        break;
      case 1:
        sum=clamp(sum+out,0.0,1.0)-out;
        sum=sum*(out==0 || out==1 ? 0.00000001 : (out*(1-out)));
        break;
      case 2:
        if(out<0)
           sum*=0.01;
        break;
      default:
        break;
     }
   matrix_ig[i]=clamp(sum,-MAX_GRADIENT,MAX_GRADIENT);
  }
//+------------------------------------------------------------------+
///\ingroup neuron_conv_opt Convolution Neuron SGD optimization Updating Weights Calculation kernel
/// Describes the process of SGD optimization weights for the Convolution Neuron (#CNeuronConvOCL).
//+------------------------------------------------------------------+
__kernel void UpdateWeightsConvMomentum(__global double *matrix_w,   ///<[in,out] Weights matrix (m+1)*n, where m - input window and n - output window
                                       __global double *matrix_g,    ///<[in] Tensor of gradients at current layer
                                       __global double *matrix_i,    ///<[in] Inputs tesor
                                       __global double *matrix_dw,   ///<[in,out] Matrix of delta weights in last correction
                                       int inputs,                   ///< Number of inputs
                                       double learning_rates,        ///< Learning rates
                                       double momentum,              ///< Momentum multiplier
                                       int window_in,                ///< Size of input window
                                       int window_out,               ///< Size of output window
                                       int step                      ///< Step size
                                       )
  {
   const int i=get_global_id(0);
   const int shift=i%(window_in+1);
   const int shift_out=(i-shift)/(window_in+1);
   int total=(inputs-window_in)%step;
   total=(inputs-window_in-total)/step+(total>0 ? 1 : 0);
   double grad=0;
   for(int t=0;t<total;t++)
     {
      if(shift!=window_in && (shift+t*window_in)>=inputs)
         break;
      grad+=matrix_g[t*window_out+shift_out]*(shift==window_in ? 1 : matrix_i[shift+t*step]);
     }
   double delta=learning_rates*grad + momentum*matrix_dw[i];
   if(!isnan(delta))
     {
      matrix_dw[i]=delta;
      matrix_w[i]=clamp(matrix_w[i]+delta,-MAX_WEIGHT,MAX_WEIGHT);
     }
  };
//+------------------------------------------------------------------+
///\ingroup neuron_conv_opt Convolution Neuron Adam optimization Updating Weights Calculation kernel
/// Describes the process of Adam optimization weights for the Convolution Neuron (#CNeuronConvOCL).
//+------------------------------------------------------------------+
__kernel void UpdateWeightsConvAdam(__global double *matrix_w,    ///<[in,out] Weights matrix (m+1)*n, where m - input window and n - output window
                                __global const double *matrix_g,  ///<[in] Tensor of gradients at current layer
                                __global const double *matrix_i,  ///<[in] Inputs tesor
                                __global double *matrix_m,        ///<[in] Matrix of first momentum
                                __global double *matrix_v,        ///<[in] Matrix of seconfd momentum
                                const int inputs,                 ///< Number of inputs
                                const double l,                   ///< Learning rates
                                const double b1,                  ///< First momentum multiplier
                                const double b2,                  ///< Second momentum multiplier
                                int window_in,                    ///< Size of input window
                                int window_out,                   ///< Size of output window
                                int step                          ///< Step size
                                )
  {
   const int i=get_global_id(0);
   if(i>window_in)
      return;
//---
   int total=(inputs-(window_in-step))%step;
   total=(inputs-(window_in-step)-total)/step+(total>0 ? 1 : 0);
   for(int out=0;out<window_out;out++)
     {
      if((window_out-out)>4)
        {
         double4 grad=0;
         int shift_w=i+out*(window_in+1);
         for(int t=0;t<total;t++)
           {
            if(i!=window_in && (i+t*window_in)>=inputs)
               break;
            grad+=(double4)(matrix_g[t*window_out+out],matrix_g[t*window_out+out+1],matrix_g[t*window_out+out+2],matrix_g[t*window_out+out+3])*(i==window_in ? 1 : matrix_i[i+t*step]);
           }
         double4 mt=clamp(b1*(double4)(matrix_m[shift_w],matrix_m[shift_w+window_in+1],matrix_m[shift_w+2*(window_in+1)],matrix_m[shift_w+3*(window_in+1)])+(1-b1)*grad,-1.0e5,1.0e5);
         double4 vt=clamp(b2*(double4)(matrix_v[shift_w],matrix_v[shift_w+window_in+1],matrix_v[shift_w+2*(window_in+1)],matrix_v[shift_w+3*(window_in+1)])+(1-b2)*pow(grad,2),1.0e-6,1.0e6);
         double4 delta=l*mt/sqrt(vt);
         double4 weight=clamp((double4)(matrix_w[shift_w],matrix_w[shift_w+(window_in+1)],matrix_w[shift_w+2*(window_in+1)],matrix_w[shift_w+3*(window_in+1)])+delta,-MAX_WEIGHT,MAX_WEIGHT);
         (double4)(matrix_w[shift_w],matrix_w[shift_w+(window_in+1)],matrix_w[shift_w+2*(window_in+1)],matrix_w[shift_w+3*(window_in+1)])=weight;
         (double4)(matrix_m[shift_w],matrix_m[shift_w+(window_in+1)],matrix_m[shift_w+2*(window_in+1)],matrix_m[shift_w+3*(window_in+1)])=mt;
         (double4)(matrix_v[shift_w],matrix_v[shift_w+(window_in+1)],matrix_v[shift_w+2*(window_in+1)],matrix_v[shift_w+3*(window_in+1)])=vt;
         out+=3;
        }
      else
        {
         double grad=0;
         int shift_w=i+out*(window_in+1);
         for(int t=0;t<total;t++)
           {
            if(i!=window_in && (i+t*window_in)>=inputs)
               break;
            grad+=matrix_g[t*window_out+out]*(i==window_in ? 1 : matrix_i[i+t*step]);
           }
         double mt=clamp(b1*matrix_m[shift_w]+(1-b1)*grad,-1.0e5,1.0e5);
         double vt=clamp(b2*matrix_v[shift_w]+(1-b2)*pow(grad,2),1.0e-6,1.0e6);
         double delta=l*mt/sqrt(vt);
         matrix_w[shift_w]=clamp(matrix_w[shift_w]+delta,-MAX_WEIGHT,MAX_WEIGHT);
         matrix_m[shift_w]=mt;
         matrix_v[shift_w]=vt;
        }
     }
  };
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff Attention Neuron Score calculation kernel                                                                  |
/// Describes the Score calculation process for the Neuron of attention layer (#CNeuronAttentionOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para43">the link.</A>
//+------------------------------------------------------------------+
__kernel void AttentionScore(__global double *querys, ///<[in] Matrix of Querys
                             __global double *keys,   ///<[in] Matrix of Keys
                             __global double *score,  ///<[out] Matrix of Scores
                             int dimension,           ///< Dimension of Key
                             int mask                 ///< 1 - calc only previous units, 0 - calc all
                             )
  {
   int q=get_global_id(0);
   int shift_q=q*dimension;
   int units=get_global_size(0);
   int shift_s=q*units;
   double koef=sqrt((double)dimension);
   if(koef<1)
      koef=1;
   double sum=0;
   for(int k=0;k<units;k++)
     {
      if(mask>0 && k>q)
        {
         score[shift_s+k]=0;
         continue;
        }
      double result=0;
      int shift_k=k*dimension;
      for(int i=0;i<dimension;i++)
         result+=(querys[shift_q+i]*keys[shift_k+i]);
      result=exp(result/koef);
      if(isnan(result))
         result=0;
      score[shift_s+k]=result;
      sum+=result;   
     }
   for(int k=0;(k<units && sum>0);k++)
      score[shift_s+k]/=sum;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff Attention Neuron Out calculation kernel
/// Describes the Attention out calculation process for the Neuron of attention layer (#CNeuronAttentionOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para43">the link.</A>
//+------------------------------------------------------------------+
__kernel void AttentionOut(__global double *scores,   ///<[in] Matrix of Scores
                           __global double *values,   ///<[in] Matrix of Values
                           __global double *inputs,   ///<[in] Inputs tesor
                           __global double *out       ///<[out] Output tesor
                           )
  {
   int units=get_global_size(0);
   int u=get_global_id(0);
   int d=get_global_id(1);
   int dimension=get_global_size(1);
   int shift=u*dimension+d;
   double result=0;
   for(int i=0;i<units;i++)
      result+=scores[u*units+i]*values[i*dimension+d];
   out[shift]=(isnan(result) ? 0 : result)+inputs[shift];
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff Kernel for calculation Sum of 2 matrixs with multiplyer.
/// Describes the calculation Sum of 2 matrixs.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para43">the link.</A>
//+------------------------------------------------------------------+
__kernel void SumMatrix(__global double *matrix1,     ///<[in] First matrix
                        __global double *matrix2,     ///<[in] Second matrix
                        __global double *matrix_out,  ///<[out] Output matrix
                        int dimension,                ///< Dimension of matrix
                        double multiplyer             ///< Multiplyer for output
                        )
  {
   const int i=get_global_id(0)*dimension;
   for(int k=0;k<dimension;k++)
      matrix_out[i+k]=(matrix1[i+k]+matrix2[i+k])*multiplyer;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff Kernel for calculation Sum of 4 matrixs with multiplyer.
/// Describes the calculation Sum of 4 matrixs.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8909#para53">the link.</A>
//+------------------------------------------------------------------+
__kernel void Sum5Matrix(__global double *matrix1,     ///<[in] First matrix
                        __global double *matrix2,     ///<[in] Second matrix
                        __global double *matrix3,     ///<[in] Third matrix
                        __global double *matrix4,     ///<[in] Fourth matrix
                        __global double *matrix5,     ///<[in] Fifth matrix
                        __global double *matrix_out,  ///<[out] Output matrix
                        int dimension,                ///< Dimension of matrix
                        double multiplyer             ///< Multiplyer for output
                        )
  {
   const int i=get_global_id(0)*dimension;
   for(int k=0;k<dimension;k++)
      matrix_out[i+k]=(matrix1[i+k]+matrix2[i+k]+matrix3[i+k]+matrix4[i+k]+matrix5[i+k])*multiplyer;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_gr Attention layer's neuron Gradients Calculation kernel
/// Describes the gradients calculation process for the Neuron of attention layer (#CNeuronAttentionOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para44">the link.</A>
/// @param[in] querys Matrix of Querys
/// @param[out] querys_g Matrix of Querys' Gradients
/// @param[in] keys Matrix of Keys
/// @param[out] keys_g Matrix of Keys' Gradients
/// @param[in] values Matrix of Values
/// @param[out] values_g Matrix of Values' Gradients
/// @param[in] scores Matrix of Scores
/// @param[in] gradient Matrix of Gradients from previous iteration
//+------------------------------------------------------------------+
__kernel void AttentionInsideGradients(__global double *querys,__global double *querys_g,
                                      __global double *keys,__global double *keys_g,
                                      __global double *values,__global double *values_g,
                                      __global double *scores,
                                      __global double *gradient)
  {
   int u=get_global_id(0);
   int d=get_global_id(1);
   int units=get_global_size(0);
   int dimension=get_global_size(1);
   double koef=sqrt((double)dimension);
   if(koef<1)
      koef=1;
   
   double vg=0;
   double qg=0;
   double kg=0;
   
   for(int iu=0;iu<units;iu++)
     {
      double g=gradient[iu*dimension+d];
      double sc=scores[iu*units+u];
      vg+=sc*g;
//---
      double sqg=0;
      double skg=0;
      for(int id=0;id<dimension;id++)
        {
         sqg+=values[iu*dimension+id]*gradient[u*dimension+id];
         skg+=values[u*dimension+id]*gradient[iu*dimension+id];
        }
      qg+=(scores[u*units+iu]==0 || scores[u*units+iu]==1 ? 0.0001 : scores[u*units+iu]*(1-scores[u*units+iu]))*sqg*keys[iu*dimension+d]/koef;
//---
      kg+=(scores[iu*units+u]==0 || scores[iu*units+u]==1 ? 0.0001 : scores[iu*units+u]*(1-scores[iu*units+u]))*skg*querys[iu*dimension+d]/koef;
     }
   int shift=u*dimension+d;
   values_g[shift]=clamp((isnan(vg) ? 0.0 : vg),-1.0,1.0);
   querys_g[shift]=clamp((isnan(qg) ? 0.0 : qg),-1.0,1.0);
   keys_g[shift]=clamp((isnan(kg) ? 0.0 : kg),-1.0,1.0);
  }
//+------------------------------------------------------------------+
///\ingroup neuron_norm Kernels of matrix normalization process
/// Describes the process of matrix normalization.
///\details Detailed description on <A HREF="https://arxiv.org/abs/1607.06450">the link.</A>
/// @param[in,out] buffer In/Out Matrix
/// @param[in] dimension Dimension of matrix
//+------------------------------------------------------------------+
__kernel void Normalize(__global double *buffer,
                        int dimension)
  {
   int n=get_global_id(0);
   int shift=n*dimension;
   if(dimension<=0)
      return;
//---
   double mean=0;
   for(int i=0;i<dimension;i++)
     {
      if(isnan(buffer[shift+i]))
         buffer[shift+i]=0;
      else
         mean+=buffer[shift+i]/dimension;
     }
   double variance=0;
   for(int i=0;i<dimension;i++)
      variance+=pow(buffer[shift+i]-mean,2)/dimension;
   variance=sqrt((isnan(variance) ? 0 : variance));
   if(variance==0)
     {
      for(int i=0;i<dimension;i++)
         variance=fmax(fabs(buffer[shift+i]-mean),variance);
     }
   for(int i=0;i<dimension;i++)
      buffer[shift+i]=(buffer[shift+i]-mean)/(variance<=1 ? 1 : variance);
  }
//+------------------------------------------------------------------+
///\ingroup neuron_norm Kernels of weights matrix normalization process
/// Describes the process of weights matrix normalization.
///\details Detailed description on <A HREF="https://arxiv.org/abs/1607.06450">the link.</A>
/// @param[in,out] buffer In/Out Matrix
/// @param[in] dimension Dimension of matrix
//+------------------------------------------------------------------+
__kernel void NormalizeWeights(__global double *buffer,
                                 int dimension)
  {
   int n=get_global_id(0);
   int shift=n*dimension;
   double sum=0;
   double k=1;
   do
     {
      for(int i=0;(i<dimension && !isnan(sum));i++)
         sum=pow(buffer[shift+i]/k,2)/dimension;
      if(isnan(sum))
         k*=10;
     }
   while(isnan(sum));
   sum=sqrt(sum);
   if(k*sum>1)
      for(int i=0;i<dimension;i++)
         buffer[shift+i]/=k*sum;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff 
/// Describes the process of concatenate 4 matrices.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8909#para52">the link.</A>
/// @param[in] input1, input2, input3, input4 Input buffers
/// @param[in] window1, window2, window3, window4 Windows for every buffer
/// @param[out] output Output buffer
//+------------------------------------------------------------------+
__kernel void ConcatenateBuffers(__global double *input1, int window1,
                                 __global double *input2, int window2,
                                 __global double *input3, int window3,
                                 __global double *input4, int window4,
                                 __global double *output)
  {
   int n=get_global_id(0);
   int shift=n*(window1+window2+window3+window4);
   int shift_in=n*window1;
   for(int i=0;i<window1;i++)
      output[shift+i]=input1[shift_in+i];
//---
   shift+=window1;
   shift_in=n*window2;
   for(int i=0;i<window2;i++)
      output[shift+i]=input2[shift_in+i];
//---
   shift+=window2;
   shift_in=n*window3;
   for(int i=0;i<window3;i++)
      output[shift+i]=input3[shift_in+i];
//---
   shift+=window3;
   shift_in=n*window4;
   for(int i=0;i<window4;i++)
      output[shift+i]=input4[shift_in+i];
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_gr 
/// Describes the process of deconcatenate matrix.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8909#para53">the link.</A>
/// @param[in] output1, output2, output3, output4 Output buffers
/// @param[in] window1, window2, window3, window4 Windows for every buffer
/// @param[out] inputs Input buffer
//+------------------------------------------------------------------+
__kernel void DeconcatenateBuffers(__global double *output1, int window1,
                                 __global double *output2, int window2,
                                 __global double *output3, int window3,
                                 __global double *output4, int window4,
                                 __global double *inputs)
  {
   int n=get_global_id(0);
//--- Head 1
   int shift=n*(window1+window2+window3+window4);
   int shift_out=n*window1;
   for(int i=0;i<window1;i++)
      output1[shift_out+i]=inputs[shift+i];
//--- Head 2
   shift+=window1;
   shift_out=n*window2;
   for(int i=0;i<window2;i++)
      output2[shift_out+i]=inputs[shift+i];
//--- Head 3
   shift+=window2;
   shift_out=n*window3;
   for(int i=0;i<window3;i++)
      output3[shift_out+i]=inputs[shift+i];
//--- Head 4
   shift+=window3;
   shift_out=n*window4;
   for(int i=0;i<window4;i++)
      output4[shift_out+i]=inputs[shift+i];
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff Multi-Heads Attention Neuron Score calculation kernel
/// Describes the Score calculation process for the Neuron of multi-heads attention layer (#CNeuronMLMHAttentionOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9025#para42">the link.</A>
//+------------------------------------------------------------------+
__kernel void MHAttentionScore(__global double *qkv,    ///<[in] Matrix of Querys, Keys, Values
                             __global double *score,  ///<[out] Matrix of Scores
                             int dimension,           ///< Dimension of Key
                             int mask                 ///< 1 - calc only previous units, 0 - calc all
                             )
  {
   int q=get_global_id(0);
   int h=get_global_id(1);
   int units=get_global_size(0);
   int heads=get_global_size(1);
//---
   int shift_q=dimension*(h+3*q*heads);
   int shift_s=units*(h+q*heads);
//---
   double koef=sqrt((double)dimension);
   if(koef<1)
      koef=1;
   double sum=0;
   for(int k=0;k<units;k++)
     {
      if(mask>0 && k>q)
        {
         score[shift_s+k]=0;
         continue;
        }
      double result=0;
      int shift_k=dimension*(h+heads*(3*k+1));
      for(int i=0;i<dimension;i++)
        {
         if((dimension-i)>4)
           {
            result+=dot((double4)(qkv[shift_q+i],qkv[shift_q+i+1],qkv[shift_q+i+2],qkv[shift_q+i+3]),
                        (double4)(qkv[shift_k+i],qkv[shift_k+i+1],qkv[shift_k+i+2],qkv[shift_k+i+3]));
            i+=3;
           }
         else
            result+=(qkv[shift_q+i]*qkv[shift_k+i]);
        }
      result=exp(clamp(result/koef,-30.0,30.0));
      if(isnan(result))
         result=0;
      score[shift_s+k]=result;
      sum+=result;   
     }
   for(int k=0;(k<units && sum>1);k++)
      score[shift_s+k]/=sum;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_ff Multi-heads Attention Neuron Out calculation kernel
/// Describes the Multi-heads Attention out calculation process for the Neuron of multi-heads attention layer (#CNeuronMLMHAttentionOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9025#para42">the link.</A>
//+------------------------------------------------------------------+
__kernel void MHAttentionOut(__global double *scores, ///<[in] Matrix of Scores
                             __global double *qkv,    ///<[in] Matrix of Values
                             __global double *out,    ///<[out] Output tesor
                             int dimension            ///< Dimension of Value
                            )
  {
   int u=get_global_id(0);
   int units=get_global_size(0);
   int h=get_global_id(1);
   int heads=get_global_size(1);
//---
   int shift_s=units*(h+heads*u);
   int shift_out=dimension*(h+heads*u);
   int layer=3*dimension*heads;
//---
   for(int d=0;d<dimension;d++)
     {
      double result=0;
      for(int v=0;v<units;v+=4)
        {
         int shift_v=dimension*(h+heads*(3*v+2))+d;
         if((units-v)>4)
           {
            result+=dot((double4)(scores[shift_s+v],scores[shift_s+v+1],scores[shift_s+v+1],scores[shift_s+v+3]),
                              (double4)(qkv[shift_v],qkv[shift_v+layer],qkv[shift_v+2*layer],qkv[shift_v+3*layer]));
           }
         else
            for(int l=0;l<(int)fmin((double)(units-v),4.0);l++)
               result+=scores[shift_s+v+l]*qkv[shift_v+l*layer];
        }
      out[shift_out+d]=result;
     }
  }
//+------------------------------------------------------------------+
///\ingroup neuron_atten_gr Attention layer's neuron Gradients Calculation kernel
/// Describes the gradients calculation process for the Neuron of attention layer (#CNeuronMLMHAttentionOCL).
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9025#para33">the link.</A>
/// @param[in] qkv Matrix of Querys, Keys and Values
/// @param[out] qkv_g Matrix of Querys', Keys' and Values' Gradients
/// @param[in] scores Matrix of Scores
/// @param[in] scores_g Matrix of Scores' Gradients
/// @param[in] gradient Matrix of Gradients from previous iteration
/// @param[in] dimension Dimension of Key vector
//+------------------------------------------------------------------+
__kernel void MHAttentionInsideGradients(__global double *qkv,__global double *qkv_g,
                                         __global double *scores,__global double *scores_g,
                                         __global double *gradient, int dimension)
  {
   int u=get_global_id(0);
   int h=get_global_id(1);
   int units=get_global_size(0);
   int heads=get_global_size(1);
   double koef=sqrt((double)dimension);
   if(koef<1)
      koef=1;

//--- Calculating score's gradients
   uint shift_s=units*(h+u*heads);
   for(int v=0;v<units;v++)
     {
      double s=scores[shift_s+v];
      if(s>0)
        {
         double sg=0;
         int shift_v=dimension*(h+heads*(3*v+2));
         int shift_g=dimension*(h+heads*v);
         for(int d=0;d<dimension;d++)
            sg+=qkv[shift_v+d]*gradient[shift_g+d];
         scores_g[shift_s+v]=sg*(s<1 ? s*(1-s) : 1)/koef;
        }
      else
         scores_g[shift_s+v]=0;
     }
   barrier(CLK_GLOBAL_MEM_FENCE);
//--- Calculating gradients for Query, Key and Value
   uint shift_qg=dimension*(h+3*u*heads);
   uint shift_kg=dimension*(h+(3*u+1)*heads);
   uint shift_vg=dimension*(h+(3*u+2)*heads);
   for(int d=0;d<dimension;d++)
     {
      double vg=0;
      double qg=0;
      double kg=0;
      for(int l=0;l<units;l++)
        {
         uint shift_q=dimension*(h+3*l*heads)+d;
         uint shift_k=dimension*(h+(3*l+1)*heads)+d;
         uint shift_g=dimension*(h+heads*l)+d;
         double sg=scores_g[shift_s+l];
         
         kg+=sg*qkv[shift_q];
         qg+=sg*qkv[shift_k];
         vg+=gradient[shift_g]*scores[shift_s+l];
        }   
      qkv_g[shift_qg+d]=qg;
      qkv_g[shift_kg+d]=kg;
      qkv_g[shift_vg+d]=vg;
     }
  }
//+------------------------------------------------------------------+