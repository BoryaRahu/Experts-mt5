/// \file
/// \brief NeuroNet.mqh
/// Library for creating Neural network for use in MQL5 experts
/// \author [DNG](https://www.mql5.com/en/users/dng)
/// \copyright Copyright 2019, DNG
//+------------------------------------------------------------------+
///\mainpage NeuronNet
/// Library for creating Neural network for use in MQL5 experts.
/// - \ref const
/// - \ref enums
/// - \ref ObjectTypes
/// - \ref group1
/// - [<b>Class Hierarchy</b>](hierarchy.html)
/// - [<b>Files</b>](files.html)
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, DNG"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include standart libraries
//+------------------------------------------------------------------+
#include <Arrays\ArrayFloat.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Arrays\ArrayObj.mqh>
#include <OpenCL\OpenCL.mqh>
#include <Math\Stat\Normal.mqh>
//+------------------------------------------------------------------+
// Defines
//+------------------------------------------------------------------+
///\defgroup const  Global constants
///@{
#define  lr 1.0e-8f ///<learning rate
#define  momentum 0.99f ///<momentum for SGD optimization
#define  WeightsMultiplier 1.0e0f
//---
/** First momentum multiplier of Adam optimization*/
#define b1   0.9f
/** Second momentum multiplier of Adam optimization*/
#define b2 0.999f
/// Pseudo-random sequence generator
#define xor128 rnd_t=(rnd_x^(rnd_x<<11)); \
               rnd_x=rnd_y; \
               rnd_y=rnd_z; \
               rnd_z=rnd_w; \
               rnd_w=(rnd_w^(rnd_w>>19))^(rnd_t^(rnd_t>>8))
///@}
//---
float eta = lr;  ///<learning rate for SGD optimization
uint rnd_x = MathRand(), rnd_y = MathRand(), rnd_z = MathRand(), rnd_w = MathRand(), rnd_t = 0;


string          com;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T1, typename T2>
T2 pow(T1 a, T2 b)
  {
   return (T2)MathPow((T2)a, b);
  }
//+------------------------------------------------------------------+
///\defgroup ObjectTypes  Defines Object types identified
///Used to identify classes in a library
///@{
//+------------------------------------------------------------------+
///\defgroup arr Arrays
///Used to identify array classes
///\{
#define defArrayConnects   0x7782   ///<Array of connections \details Identified class #CArrayCon
#define defLayer           0x7787   ///<Layer of neurons \details Identified class #CLayer
#define defArrayLayer      0x7788   ///<Array of layers \details Identified class #CArrayLayer
#define defNet             0x7790   ///<Neuron Net \details Identified class #CNet
///\}
///\defgroup cpu CPU
///Used to identify classes with CPU calculation
///\{
#define defConnect         0x7781   ///<Connection \details Identified class #CConnection
#define defNeuronBase      0x7783   ///<Neuron base type \details Identified class #CNeuronBase
#define defNeuron          0x7784   ///<Full connected neuron \details Identified class #CNeuron
#define defNeuronConv      0x7785   ///<Convolution neuron \details Identified class #CNeuronConv
#define defNeuronProof     0x7786   ///<Proof neuron \details Identified class #CNeuronProof
#define defNeuronLSTM      0x7791   ///<LSTM Neuron \details Identified class #CNeuronLSTM
///\}
///\defgroup gpu GPU
///Used to identify classes with GPU calculation
///\{
#define defBufferDouble    0x7882   ///<Data Buffer OpenCL \details Identified class #CBufferFloat
#define defNeuronBaseOCL   0x7883   ///<Neuron Base OpenCL \details Identified class #CNeuronBaseOCL
#define defNeuronConvOCL   0x7885   ///<Conolution neuron OpenCL \details Identified class #CNeuronConvOCL
#define defNeuronProofOCL  0x7886   ///<Proof neuron OpenCL \details Identified class #CNeuronProofOCL
#define defNeuronAttentionOCL 0x7887   ///<Attention neuron OpenCL \details Identified class #CNeuronAttentionOCL
#define defNeuronMHAttentionOCL 0x7888   ///<Multi-Head Attention neuron OpenCL \details Identified class #CNeuronMHAttentionOCL
#define defNeuronMLMHAttentionOCL 0x7889   ///<Multilayer multi-headed attention neuron OpenCL \details Identified class #CNeuronMLMHAttentionOCL
#define defNeuronDropoutOCL   0x7890      ///<Dropout neuron OpenCL \details Identified class #CNeuronDropoutOCL
#define defNeuronBatchNormOCL 0x7891      ///<Batchnorm neuron OpenCL \details Identified class #CNeuronBatchNormOCL
#define defNeuronVAEOCL 0x7892      ///<VAE neuron OpenCL \details Identified class #CVAE
#define defNeuronLSTMOCL      0x7793   ///<LSTM Neuron \details Identified class #CNeuronLSTMOCL
///\}
///@}
//#define defNeuronLSTMOCL   0x7884
//+------------------------------------------------------------------+
///\defgroup group1 Defines for OpenCL kernels identified
/// Used as indexes when calling functions OpenCL.
///@{
///\defgroup neuron_base Neuron Base
/// Describes the process for the Neuron Base.
///\details Detailed description on [the link.](https://www.mql5.com/ru/articles/8435#para4)
///@{
///\defgroup neuron_base_ff Feed Forward proccess kernel
/// Describes the forward path process for the Neuron Base.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para41">the link.</A>
///@{
#define def_k_FeedForward     0  ///< Index of #FeedForward kernel
#define def_k_ff_matrix_w     0  ///< Weights matrix (m+1)*n, where m - number of neurons in layer and n - number of outputs (neurons in next layer)
#define def_k_ff_matrix_i     1  ///< Inputs tesor
#define def_k_ff_matrix_o     2  ///< Output tensor
#define def_k_ff_inputs       3  ///< Number of inputs
#define def_k_ff_activation   4  ///< Activation type (#ENUM_ACTIVATION)
///@}
///\defgroup neuron_base_gr Gradients Calculation kernels
/// Describes the process of gradients calculation for the Neuron Base.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para42">the link.</A>
///@{
#define def_k_CalcOutputGradient 1  ///< Index of Output gradients calculation kernel (#CalcOutputGradient)
#define def_k_cog_matrix_t       0  ///< Target tensor
#define def_k_cog_matrix_o       1  ///< Output tensor
#define def_k_cog_matrix_ig      2  ///< Tensor of gradients at previous layer
#define def_k_cog_activation     3  ///< Activation type (#ENUM_ACTIVATION)
#define def_k_cog_error          4  ///< Error
//---
#define def_k_CalcHiddenGradient 2  ///< Index of Hidden gradients calculation kernel (#CalcHiddenGradient)
#define def_k_chg_matrix_w       0  ///< Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
#define def_k_chg_matrix_g       1  ///< Tensor of gradients at current layer
#define def_k_chg_matrix_o       2  ///< Output tensor
#define def_k_chg_matrix_ig      3  ///< Tensor of gradients at previous layer
#define def_k_chg_outputs        4  ///< Number of outputs
#define def_k_chg_activation     5  ///< Activation type (#ENUM_ACTIVATION)
///@}
///\defgroup neuron_base_opt Updating Weights Calculation kernel
/// Describes the process of optimization weights for the Neuron Base.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para43">the link.</A>
/// For Adam optimization look <A HREF="https://www.mql5.com/ru/articles/8598#para31">the link.</A>
///@{
#define def_k_UpdateWeightsMomentum      3   ///< Index SGD optomization Update weights kernel (#UpdateWeightsMomentum)
#define def_k_uwm_matrix_w        0  ///< SGD Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
#define def_k_uwm_matrix_g        1  ///< SGD Tensor of gradients at current layer
#define def_k_uwm_matrix_i        2  ///< SGD Inputs tesor
#define def_k_uwm_matrix_dw       3  ///< SGD Matrix of delta weights in last correction
#define def_k_uwm_inputs          4  ///< SGD Number of inputs
#define def_k_uwm_learning_rates  5  ///< SGD Learning rates
#define def_k_uwm_momentum        6  ///< SGD Momentum multiplier
//---
#define def_k_UpdateWeightsAdam   4  ///< Index Adam optomization Update weights kernel (#UpdateWeightsAdam)
#define def_k_uwa_matrix_w        0  ///< Adam Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
#define def_k_uwa_matrix_g        1  ///< Adam Tensor of gradients at current layer
#define def_k_uwa_matrix_i        2  ///< Adam Inputs tesor
#define def_k_uwa_matrix_m        3  ///< Adam Matrix of first momentum
#define def_k_uwa_matrix_v        4  ///< Adam Matrix of seconfd momentum
#define def_k_uwa_inputs          5  ///< Adam Number of inputs
#define def_k_uwa_l               6  ///< Adam Learning rates
#define def_k_uwa_b1              7  ///< Adam First momentum multiplier
#define def_k_uwa_b2              8  ///< Adam Second momentum multiplier
//---
#define def_k_UpdateWeightsLS    28  ///< Index Least Squares optomization Update weights kernel (#UpdateWeightsLS)
#define def_k_uwls_matrix_w       0  ///< Least Squares Weights matrix (m+1)*n, where m - number of neurons in previous layer and n - number of neurons in current layer
#define def_k_uwls_matrix_g       1  ///< Least Squares Tensor of gradients at current layer
#define def_k_uwls_matrix_i       2  ///< Least Squares Inputs tesor
#define def_k_uwls_matrix_xg      3  ///< Least Squares Matrix of summ x*g
#define def_k_uwls_matrix_xx      4  ///< Least Squares Matrix of summ x*x
#define def_k_uwls_inputs         5  ///< Least Squares Number of inputs
#define def_k_uwls_l              6  ///< Least Squares Learning rates
#define def_k_uwls_update         7  ///< Least Squares Update flag
///@}
///@}
//---
///\defgroup neuron_proof Pooling layer's neuron
/// Describes the process for the Neuron of pooling layer.
///@{
///\defgroup neuron_proof_ff Pooling layer's neuron Feed Forward
/// Describes the feed forward process for the Neuron of pooling layer.
///@{
#define def_k_FeedForwardProof    5  ///< Index of the kernel of the Pooling neuron for Feed forward process (#FeedForwardProof)
#define def_k_ffp_matrix_i        0  ///< Inputs tesor
#define def_k_ffp_matrix_o        1  ///< Output tensor
#define def_k_ffp_inputs          2  ///< Number of inputs
#define def_k_ffp_window          3  ///< Size of input window
#define def_k_ffp_step            4  ///< Step size
///@}
//---
///\defgroup neuron_proof_gr Pooling layer's neuron Gradients Calculation kernels
/// Describes the gradient calculation process for the Neuron of pooling layer.
///@{
#define def_k_CalcInputGradientProof 6  ///< Index of the kernel of the Pooling neuron to transfer gradient to previous layer (#CalcInputGradientProof)  
#define def_k_cigp_matrix_i      0  ///< Inputs tesor
#define def_k_cigp_matrix_g      1  ///< Tensor of gradients at current layer
#define def_k_cigp_matrix_o      2  ///< Output tensor
#define def_k_cigp_matrix_ig     3  ///< Tensor of gradients at previous layer
#define def_k_cigp_outputs       4  ///< Number of outputs
#define def_k_cigp_window        5  ///< Size of input window
#define def_k_cigp_step          6  ///< Step size
///@}
///@}
//---
///\defgroup neuron_conv Convolution layer's neuron
/// Describes the process for the Neuron of convolution layer.
///@{
///\defgroup neuron_conv_ff Convolution layer's neuron Feed Forward
/// Describes the feed forward process for the Neuron of convolution layer.
///@{
#define def_k_FeedForwardConv    7  ///< Index of the kernel of the convolution neuron for Feed forward process (#FeedForwardConv)
#define def_k_ffc_matrix_w       0  ///< Weights matrix (m+1)*n, where m - input window and n - output window
#define def_k_ffc_matrix_i       1  ///< Inputs tesor
#define def_k_ffc_matrix_o       2  ///< Output tensor
#define def_k_ffc_inputs         3  ///< Number of inputs
#define def_k_ffc_step           4  ///< Step size
#define def_k_ffc_window_in      5  ///< Size of input window
#define def_k_ffс_window_out     6  ///< Size of output window
#define def_k_ffc_activation     7  ///< Activation type (#ENUM_ACTIVATION)
///@}
//---
///\defgroup neuron_conv_gr Convolution layer's neuron Gradients Calculation kernels
/// Describes the gradient calculation process for the Neuron of convolution layer.
///@{
#define def_k_CalcHiddenGradientConv 8  ///< Index of the kernel of the convolution neuron to transfer gradient to previous layer (#CalcHiddenGradientConv)
#define def_k_chgc_matrix_w      0  ///< Weights matrix (m+1)*n, where m - input window and n - output window
#define def_k_chgc_matrix_g      1  ///< Tensor of gradients at current layer
#define def_k_chgc_matrix_o      2  ///< Output tensor
#define def_k_chgc_matrix_ig     3  ///< Tensor of gradients at previous layer
#define def_k_chgc_outputs       4  ///< Number of outputs
#define def_k_chgc_step          5  ///< Step size
#define def_k_chgc_window_in     6  ///< Size of input window
#define def_k_chgc_window_out    7  ///< Size of output window
#define def_k_chgc_activation    8  ///< Activation type (#ENUM_ACTIVATION)
///@}
//---
///\defgroup neuron_conv_opt Convolution layer's neuron Update weights kernels
/// Describes the optimization process for the Neuron of convolution layer.
///@{
#define def_k_UpdateWeightsConvMomentum      9  ///< Index of the kernel of the convolution neuron to update weights SGD (#UpdateWeightsConvMomentum)
#define def_k_uwcm_matrix_w       0  ///< Weights matrix (m+1)*n, where m - input window and n - output window
#define def_k_uwcm_matrix_g       1  ///< Tensor of gradients at current layer
#define def_k_uwcm_matrix_i       2  ///< Inputs tesor
#define def_k_uwcm_matrix_dw      3  ///< Matrix of delta weights in last correction
#define def_k_uwcm_inputs         4  ///< Number of inputs
#define def_k_uwcm_learning_rates 5  ///< Learning rates
#define def_k_uwcm_momentum       6  ///< Momentum multiplier
#define def_k_uwcm_window_in      7  ///< Size of input window
#define def_k_uwcm_window_out     8  ///< Size of output window
#define def_k_uwcm_step           9  ///< Step size
//---
#define def_k_UpdateWeightsConvAdam   10  ///< Index of the kernel of the convolution neuron to update weights Adam (#UpdateWeightsConvAdam)
#define def_k_uwca_matrix_w      0  ///< Weights matrix (m+1)*n, where m - input window and n - output window
#define def_k_uwca_matrix_g      1  ///< Tensor of gradients at current layer
#define def_k_uwca_matrix_i      2  ///< Inputs tesor
#define def_k_uwca_matrix_m      3  ///< Matrix of first momentum
#define def_k_uwca_matrix_v      4  ///< Matrix of seconfd momentum
#define def_k_uwca_inputs        5  ///< Number of inputs
#define def_k_uwca_l             6  ///< Learning rates
#define def_k_uwca_b1            7  ///< First momentum multiplier
#define def_k_uwca_b2            8  ///< Second momentum multiplier
#define def_k_uwca_window_in     9  ///< Size of input window
#define def_k_uwca_window_out    10  ///< Size of output window
#define def_k_uwca_step          11  ///< Step size
//---
#define def_k_UpdateWeightsConvLS   29  ///< Index of the kernel of the convolution neuron to update weights Least Squares(#UpdateWeightsConvLS)
#define def_k_uwcls_matrix_w     0  ///< Weights matrix (m+1)*n, where m - input window and n - output window
#define def_k_uwcls_matrix_g     1  ///< Tensor of gradients at current layer
#define def_k_uwcls_matrix_i     2  ///< Inputs tesor
#define def_k_uwcls_matrix_xg    3  ///< Matrix of first momentum
#define def_k_uwcls_matrix_xx    4  ///< Matrix of seconfd momentum
#define def_k_uwcls_inputs       5  ///< Number of inputs
#define def_k_uwcls_l            6  ///< Learning rates
#define def_k_uwcls_update       7  ///< Update flag
#define def_k_uwcls_window_in    8  ///< Size of input window
#define def_k_uwcls_window_out   9  ///< Size of output window
#define def_k_uwcls_step         10  ///< Step size
///@}
///@}
//---
///\defgroup neuron_atten Attention layer's neuron
/// Describes the process for the Neuron of attention layer.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para4">the link.</A>
///@{
///\defgroup neuron_atten_ff Attention layer's neuron Feed Forward
/// Describes the feed forward process for the Neuron of attention layer.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para43">the link.</A>
///@{
#define def_k_AttentionScore     11 ///< Index of the kernel of the attention neuron to calculate score matrix (#AttentionScore)
#define def_k_as_querys          0  ///< Matrix of Querys
#define def_k_as_keys            1  ///< Matriz of Keys
#define def_k_as_score           2  ///< Matrix of Scores
#define def_k_as_dimension       3  ///< Dimension of Key
#define def_k_as_mask            4  ///< 1 - calc only previous units, 0 - calc all
//---
#define def_k_AttentionOut       12 ///< Index of the Attention Neuron Output calculation kernel (#AttentionOut)
#define def_k_aout_scores        0  ///< Matrix of Scores
#define def_k_aout_values        1  ///< Matrix of Values
#define def_k_aout_inputs        2  ///< Inputs tesor
#define def_k_aout_out           3  ///< Output tesor
//---
#define def_k_MatrixSum          13 ///< Index of the kernel for calculation Sum of 2 matrix with multiplyer (#SumMatrix)
#define def_k_sum_matrix1        0  ///< First matrix
#define def_k_sum_matrix2        1  ///< Second matrix
#define def_k_sum_matrix_out     2  ///< Output matrix
#define def_k_sum_dimension      3  ///< Dimension of matrix
#define def_k_sum_multiplyer     4  ///< Multiplyer for output
//---
#define def_k_Matrix5Sum          19 ///< Index of the kernel for calculation Sum of 2 matrix with multiplyer (#SumMatrix)
#define def_k_sum5_matrix1        0  ///< First matrix
#define def_k_sum5_matrix2        1  ///< Second matrix
#define def_k_sum5_matrix3        2  ///< Third matrix
#define def_k_sum5_matrix4        3  ///< Fourth matrix
#define def_k_sum5_matrix5        4  ///< Fifth matrix
#define def_k_sum5_matrix_out     5  ///< Output matrix
#define def_k_sum5_dimension      6  ///< Dimension of matrix
#define def_k_sum5_multiplyer     7  ///< Multiplyer for output
//---
#define def_k_MHAttentionScore    20 ///< Index of the kernel of the multi-heads attention neuron to calculate score matrix (#MHAttentionScore)
#define def_k_mhas_qkv            0  ///< Matrix of Queries, Keys, Values
#define def_k_mhas_score          1  ///< Matrix of Scores
#define def_k_mhas_dimension      2  ///< Dimension of Key
#define def_k_mhas_mask           3  ///< 1 - calc only previous units, 0 - calc all
//---
#define def_k_MHAttentionOut      21 ///< Index of the kernel of the multi-heads attention neuron to calculate multi-heads out matrix (#MHAttentionOut)
#define def_k_mhao_score          0  ///< Matrix of Scores
#define def_k_mhao_qkv            1  ///< Matrix of Queries, Keys, Values
#define def_k_mhao_out            2  ///< Matrix of Outputs
#define def_k_mhao_dimension      3  ///< Dimension of Key
//---
#define def_k_ConcatenateMatrix  17 ///< Index of the Multi Head Attention Neuron Concatenate Output kernel (#ConcatenateBuffers)
#define def_k_conc_input1        0  ///< Matrix of Buffer 1
#define def_k_conc_window1       1  ///< Window of Buffer 1
#define def_k_conc_input2        2  ///< Matrix of Buffer 2
#define def_k_conc_window2       3  ///< Window of Buffer 2
#define def_k_conc_input3        4  ///< Matrix of Buffer 3
#define def_k_conc_window3       5  ///< Window of Buffer 3
#define def_k_conc_input4        6  ///< Matrix of Buffer 4
#define def_k_conc_window4       7  ///< Window of Buffer 4
#define def_k_conc_out           8  ///< Output tesor
///@}
//---
///\defgroup neuron_atten_gr Attention layer's neuron Gradients Calculation
/// Describes the gradients calculation process for the Neuron of attention layer.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para44">the link.</A>
///@{
#define def_k_AttentionGradients 14    ///< Index of the kernel for gradients calculation process (#AttentionInsideGradients)
#define def_k_ag_querys          0     ///< Matrix of Querys
#define def_k_ag_querys_g        1     ///< Matrix of Querys' Gradients
#define def_k_ag_keys            2     ///< Matrix of Keys
#define def_k_ag_keys_g          3     ///< Matrix of Keys' Gradients
#define def_k_ag_values          4     ///< Matrix of Values
#define def_k_ag_values_g        5     ///< Matrix of Values' Gradients
#define def_k_ag_scores          6     ///< Matrix of Scores
#define def_k_ag_gradient        7     ///< Matrix of Gradients from previous iteration
//---
#define def_k_DeconcatenateMatrix 18 ///< Index of the Multi Head Attention Neuron Deconcatenate Output kernel (#DeconcatenateBuffers)
#define def_k_dconc_output1       0  ///< Matrix of Buffer 1
#define def_k_dconc_window1       1  ///< Window of Buffer 1
#define def_k_dconc_output2       2  ///< Matrix of Buffer 2
#define def_k_dconc_window2       3  ///< Window of Buffer 2
#define def_k_dconc_output3       4  ///< Matrix of Buffer 3
#define def_k_dconc_window3       5  ///< Window of Buffer 3
#define def_k_dconc_output4       6  ///< Matrix of Buffer 4
#define def_k_dconc_window4       7  ///< Window of Buffer 4
#define def_k_dconc_inputs        8  ///< Input tesor
//---
#define def_k_MHAttentionGradients  22    ///< Index of the kernel for gradients calculation process (#AttentionInsideGradients)
#define def_k_mhag_qkv              0     ///< Matrix of Queries, Keys, Values
#define def_k_mhag_qkv_g            1     ///< Matrix of Gradients to Queries, Keys, Values
#define def_k_mhag_score            2     ///< Matrix of Scores
#define def_k_mhag_score_g          3     ///< Matrix of Scores Gradients
#define def_k_mhag_gradient         4     ///< Matrix of Gradients from previous iteration
#define def_k_mhag_dimension        5     ///< Dimension of Key
//---
#define def_k_Dropout               23    ///< Index of the kernel for Dropout process (#Dropout)
#define def_k_dout_input            0     ///< Inputs Tensor
#define def_k_dout_map              1     ///< Map Tensor
#define def_k_dout_out              2     ///< Out Tensor
#define def_k_dout_dimension        3     ///< Dimension of Inputs
///@}
///@}
//---
///\defgroup neuron_norm Kernels of matrix normalization process
/// Describes the process of matrix normalization.
///\details Detailed description on <A HREF="https://arxiv.org/abs/1607.06450">the link.</A>
///@{
#define def_k_Normilize          15    ///< Index of the kernel for matrix normalization (#Normalize)
#define def_k_norm_buffer        0     ///< In/Out Matrix
#define def_k_norm_dimension     1     ///< Dimension of matrix
//---
#define def_k_NormilizeWeights   16    ///< Index of the kernel for weights matrix normalization (#NormalizeWeights)
//---
#define def_k_BatchFeedForward         24 ///< Index of the kernel for Batch Normalization Feed Forward process (#CNeuronBathcNormOCL)
#define def_k_bff_inputs               0  ///< Inputs data tenzor
#define def_k_bff_options              1  ///< Tenzor of variables
#define def_k_bff_output               2  ///< Tenzor of output data
#define def_k_bff_batch                3  ///< Batch size
#define def_k_bff_optimization         4  ///< Optimization type
#define def_k_bff_activation           5  ///< Activation type
//---
#define def_k_CalcHiddenGradientBatch   25 ///< Index of the Kernel of the Batch neuron to transfer gradient to previous layer (#CNeuronBathcNormOCL)
#define def_k_bchg_options             0  ///<[in] Options matrix m*(7 or 9), where m - Number of neurons in previous layer
#define def_k_bchg_matrix_g            1  ///<[in] Tensor of gradients at current layer
#define def_k_bchg_matrix_i            2  ///<[in] Tensor of previous layer output
#define def_k_bchg_matrix_ig           3  ///<[out] Tensor of gradients at previous layer
#define def_k_bchg_activation          4  ///< Activation type (#ENUM_ACTIVATION)
#define def_k_bchg_batch               5  ///< Batch size
#define def_k_bchg_optimization        6  ///< Optimization type
//---
#define def_k_UpdateBatchOptionsMomentum  26 ///< Index of the kernel for Describe the process of SGD optimization options for the Batch normalization Neuron (#CNeuronBatchNormOCL).
#define def_k_buom_options                0  ///<[in] Options matrix m*(7 or 9), where m - Number of neurons in previous layer
#define def_k_buom_matrix_g               1  ///<[in] Tensor of gradients at current layer
#define def_k_buom_learning_rates         2  ///< Learning rates
#define def_k_buom_momentum               3  ///< Momentum multiplier
//---
#define def_k_UpdateBatchOptionsAdam      27 ///< Index of the kernel for Describe the process of Adam optimization options for the Batch normalization Neuron (#CNeuronBatchNormOCL).
#define def_k_buoa_options                0  ///<[in] Options matrix m*(7 or 9), where m - Number of neurons in previous layer
#define def_k_buoa_matrix_g               1  ///<[in] Tensor of gradients at current layer
#define def_k_buoa_l                      2  ///< Learning rates
#define def_k_buoa_b1                     3  ///< First momentum multiplier
#define def_k_buoa_b2                     4  ///< Second momentum multiplier
///@}
///\defgroup VAE neuron Kernels of Variant Aoutoencodre
/// Describes the process of Variant Aoutoencodre.
///@{
#define def_k_VAEFeedForward             30
#define def_k_vaeff_inputs                0
#define def_k_vaeff_random                1
#define def_k_vaeff_outputd               2
//---
#define def_k_VAECalcHiddenGradient      31
#define def_k_vaehg_input                 0
#define def_k_vaehg_inp_grad              1
#define def_k_vaehg_random                2
#define def_k_vaehg_gradient              3
#define def_k_vaehg_kld_mult              4
///@}
///\defgroup LSTM neuron Kernels of RNN unit
/// Describes the process of RNN.
///@{
#define def_k_LSTM_FeedForward            32
#define def_k_lstmff_inputs               0
#define def_k_lstmff_inputs_size          1
#define def_k_lstmff_weights              2
#define def_k_lstmff_concatenated         3
#define def_k_lstmff_memory               4
#define def_k_lstmff_outputs              5
//---
#define def_k_LSTM_ConcatenatedGradient   33
#define def_k_lstmcg_gradient             0
#define def_k_lstmcg_concatenated_gradient 1
#define def_k_lstmcg_memory               2
#define def_k_lstmcg_concatenated         3
//---
#define def_k_LSTM_HiddenGradient         34
#define def_k_lstmhg_concatenated_gradient 0
#define def_k_lstmhg_inputs_gradient      1
#define def_k_lstmhg_weights_gradient     2
#define def_k_lstmhg_hidden_state         3
#define def_k_lstmhg_inputs               4
#define def_k_lstmhg_weeights             5
#define def_k_lstmhg_output               6
#define def_k_lstmhg_hidden_size          7
#define def_k_lstmhg_inputs_size          8
//---
#define def_k_LSTM_UpdateWeightsAdam      35
#define def_k_lstmuw_weights              0
#define def_k_lstmuw_weights_gradient     1
#define def_k_lstmuw_matrix_m             2
#define def_k_lstmuw_matrix_v             3
#define def_k_lstmuw_l                    4
#define def_k_lstmuw_b1                   5
#define def_k_lstmuw_b2                   6
///@}
///@}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#resource "NeuroNet.cl" as string cl_program
///\defgroup enums ENUM
///@{
//+------------------------------------------------------------------+
/// Enum of activation formula used
//+------------------------------------------------------------------+
enum ENUM_ACTIVATION
  {
   None = -1, ///< Without activation formula
   TANH,    ///< Use \f$tanh(x)\f$ for activation neuron
   SIGMOID, ///< Use \f$\frac{1}{1+e^x}\f$ for activation neuron
   LReLU    ///< For activation neuron use LReLU \f[\left\{ \begin{array} a x>=0, \ x \\x<0, \ 0.01*x \end{array} \right.\f]
  };
//+------------------------------------------------------------------+
/// Enum of optimization method used
//+------------------------------------------------------------------+
enum ENUM_OPTIMIZATION
  {
   SGD,  ///< Stochastic gradient descent
   ADAM, ///< Adam
   LS    ///< Least Squares
  };
///@}
//+------------------------------------------------------------------+
///\class CConnection
///\brief Class of connection to anothe neuron
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para51">the link.</A>
//+------------------------------------------------------------------+
class CConnection : public CObject
  {
public:
   float             weight;        ///< Current weight
   float             deltaWeight;   ///< last delta of weight used in SGD optimization
   float             mt;            ///< First moment in Adam optimization
   float             vt;            ///< Second moment in Adam optimization

   /** Constructor @param[in] w initial weight */ CConnection(float w) { weight = w; deltaWeight = 0; mt = 0; vt = 0; }
   /** Destructor */ ~CConnection() {};
   //--- methods for working with files
   virtual bool      Save(int const file_handle);  ///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);  ///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual int       Type(void)   const   {  return defConnect;   }  ///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CConnection::Save(int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
//---
   if(FileWriteDouble(file_handle, weight) <= 0)
      return false;
   if(FileWriteDouble(file_handle, deltaWeight) <= 0)
      return false;
   if(FileWriteDouble(file_handle, mt) <= 0)
      return false;
   if(FileWriteDouble(file_handle, vt) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CConnection::Load(int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
//---
   weight = (float)FileReadDouble(file_handle);
   deltaWeight = (float)FileReadDouble(file_handle);
   mt = (float)FileReadDouble(file_handle);
   vt = (float)FileReadDouble(file_handle);
//---
   return true;
  }
//+------------------------------------------------------------------+
///\class CArrayCon
///\brief Array of connections to anothe neuron
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para51">the link.</A>
//+------------------------------------------------------------------+
class CArrayCon  :    public CArrayObj
  {
public:
   /** Constructor */
                     CArrayCon(void) {};
   /** Destructor */ ~CArrayCon(void) {};
   //---
   virtual bool      CreateElement(int const index); ///< Method for cearing new element by index @param[in] index Index of new element @return logical result of operation
   virtual void      IncreaseTotal()   {  m_data_total++;   } ///< Increase number of elements in array
   virtual int       Type(void)  const { return defArrayConnects; }  ///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CArrayCon::CreateElement(int index)
  {
   if(index < 0 || index >= m_data_max)
      return false;
//---
   xor128;
   float weigh = (float)(rnd_w / UINT_MAX - 0.5);
   m_data[index] = new CConnection(weigh / 100);
   if(!CheckPointer(m_data[index]) != POINTER_INVALID)
      return false;
//---
   return (true);
  }
//+------------------------------------------------------------------+
///\class CLayer
/// Class of neurons collection in one layer of Neural Net.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para53">the link.</A>
//+------------------------------------------------------------------+
class CLayer;
//+------------------------------------------------------------------+
///\class CNeuronBase
/// The base class of neuron.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para52">the link.</A>
//+------------------------------------------------------------------+
class CNeuronBase    :  public CObject
  {
protected:
   float             outputVal;  ///< Output value
   float             prevVal;    ///< Previous output value
   uint              m_myIndex;  ///< Index of neuron in layer
   float             gradient;   ///< Current gradient of neuron
   CArrayCon         *Connections;  ///< Array of connections with neurons in next layer
   ENUM_ACTIVATION   activation;    ///< Activation type (#ENUM_ACTIVATION)
   ENUM_OPTIMIZATION optimization;  ///< Optimization method (#ENUM_OPTIMIZATION)
   int               t;             ///< Count of iterations
   //---
   virtual bool      feedForward(CLayer *prevLayer)               {  return false;    }   ///< Feed Forward method.@param prevLayer Pointer to previos layer.
   virtual bool      calcHiddenGradients(CLayer *&nextLayer)     {  return false;     }   ///< Method to transfer gradient to previous layer. @param nextLayer Pointer to next layer.
   virtual bool      updateInputWeights(CLayer *&prevLayer)       {  return false;    }   ///< Method for updating weights.@param prevLayer Pointer to previos layer.
   virtual float     activationFunction(float x);                                        ///< Method to calculate activation function.@param x Input data. @return Result of activation function.
   virtual float     SigmoidFunction(float x)                    {  return (float)MathPow(1 + exp(-x), -1); } ///< Calculating Sigmoid \f$\frac{1}{1+e^x}\f$.@param x Input data.@return Result of calculation
   virtual float     TanhFunction(float x)                       {  return (float)tanh(x);   }              ///< Calculating \f$tanh(x)\f$.@param x Input data.@return Result of calculation
   virtual CLayer    *getOutputLayer(void)                        {  return NULL;      }  ///< Method for getting a pointer to the resulting neural layer. Not used in fully connected neural networks.@return Pointer to layer.
public:
   /** Constructor */
                     CNeuronBase(void);
   /** Destructor */~CNeuronBase(void);
   virtual bool      Init(uint numOutputs, uint myIndex, ENUM_OPTIMIZATION optimization_type);  ///< Method of initialization class.@param numOutputs Number of connections to next layer.@param myIndex Index of neuron in layer.@param optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   virtual void      SetActivationFunction(ENUM_ACTIVATION value) {  activation = value; }      ///< Set the type of activation function (#ENUM_ACTIVATION)
   //---
   //static float            eta;
   static float            alpha;        ///< Multiplier to momentum in SGD optimization
   //---
   virtual void      setOutputVal(float val)                     {  prevVal = outputVal;   outputVal = val;    } ///< Set the output value
   virtual float     getOutputVal()                               {  return outputVal; }                      ///< Return result of feed forward operations.@return Output value
   virtual float     getPrevVal()                                 {  return prevVal;   }                      ///< Return result of feed forward operations at previous iteration.@return Previous output value
   virtual void      setGradient(float val)                      {  gradient = val;     }                    ///< Set gradient value to neuron.
   virtual float     getGradient()                                {  return gradient;  }                      ///< Return gradient of neuron.@return Gradient
   virtual CArrayCon *getConnections()                            {  return Connections;}                     ///< Method to get access to array of connections.@return Pointer to connections array
   virtual float     activationFunctionDerivative(float x);   ///< Calculate derivative of activation function.@param[in] x Input data@return Derivative
   virtual float     SigmoidFunctionDerivative(float x)          {  return x * (1 - x);   } ///< Calculate derivative of Sigmoid function.@param x Input data@return Derivative
   virtual float     TanhFunctionDerivative(float x)             {  return (1 + x) * (1 - x);  } ///< Calculate derivative of \f$tanh(x)\f$.@param x Input data@return Derivative
   //---
   virtual bool      feedForward(CObject *&SourceObject);            ///< Dispatch method for defining the subroutine for Feed Forward process.@param SourceObject Pointer to previos layer.
   virtual bool      calcHiddenGradients(CObject *&TargetObject);    ///< Dispatch method for defining the subroutine for transfer gradient to previous layer.@param TargetObject Pointer to next layer.
   virtual bool      updateInputWeights(CObject *&SourceObject);     ///< Dispatch method for defining the subroutine for updating weights.@param SourceObject Pointer to previos layer.
   //---
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle)///< Load method @param[in] file_handle handle of file @return logical result of operation
     {
      activation = (ENUM_ACTIVATION)FileReadInteger(file_handle, INT_VALUE);
      optimization = (ENUM_OPTIMIZATION)FileReadInteger(file_handle, INT_VALUE);
      t = (ENUM_OPTIMIZATION)FileReadInteger(file_handle, INT_VALUE);
      return(Connections.Load(file_handle));
     }
   //---
   virtual int       Type(void)        const                      {  return defNeuronBase;                  }///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//float CNeuronBase::eta=0.0000001;   // net learning rate
float CNeuronBase::alpha = (float)0.8;     // momentum
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronBase::CNeuronBase(void)  :
   outputVal(1),
   gradient(0),
   activation(TANH),
   t(1),
   optimization(SGD)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronBase::~CNeuronBase(void)
  {
   if(CheckPointer(Connections) != POINTER_INVALID)
      delete Connections;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::Init(uint numOutputs, uint myIndex, ENUM_OPTIMIZATION optimization_type)
  {
   if(CheckPointer(Connections) == POINTER_INVALID)
     {
      Connections = new CArrayCon();
      if(CheckPointer(Connections) == POINTER_INVALID)
         return false;
     }
//---
   if(Connections.Reserve(fmax(numOutputs, 1)))
      for(uint c = 0; c < numOutputs; c++)
        {
         if(!Connections.CreateElement(c))
            return false;
         Connections.IncreaseTotal();
        }
//---
   m_myIndex = myIndex;
   optimization = optimization_type;
   return true;
  }
//+------------------------------------------------------------------+
///\class CNeuron
/// Class of neuron for full connected layers.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para52">the link.</A>
//+------------------------------------------------------------------+
class CNeuron  :  public CNeuronBase
  {
private:
   virtual bool      feedForward(CLayer *prevLayer);                          ///< Feed Forward method.@param prevLayer Pointer to previos layer.
   virtual bool      calcHiddenGradients(CLayer *&nextLayer);                 ///< Method to transfer gradient to previous layer. @param nextLayer Pointer to next layer.
   virtual bool      updateInputWeights(CLayer *&prevLayer);                  ///< Method for updating weights.@param prevLayer Pointer to previos layer.

public:
   /** Constructor */
                     CNeuron(void)  {};
   /** Destructor */~CNeuron(void) { Connections.Shutdown(); }
   //---
   virtual bool      calcOutputGradients(float targetVals);                  ///< Method of output gradients calculation.@param targetVals Traget value
   virtual float     sumDOW(CLayer *&nextLayer) ;                             ///< A method for collecting gradients from the next layer.@param[in] nextLayer Pointer to next layer@return Total gradient to neuron.
   virtual int       Type(void)   const   {  return defNeuron;   } ///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuron::updateInputWeights(CLayer *&prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
   float lt = (float)(eta * sqrt(1 - pow(b2, t)) / (1 - pow(b1, t)));
   int total = prevLayer.Total();
   for(int n = 0; n < total && !IsStopped(); n++)
     {
      CNeuron *neuron = prevLayer.At(n);
      CConnection *con = neuron.Connections.At(m_myIndex);
      if(CheckPointer(con) == POINTER_INVALID)
         continue;
      if(optimization == SGD)
         con.weight += con.deltaWeight = (gradient != 0 ? eta * neuron.getOutputVal() * gradient : 0) + (con.deltaWeight != 0 ? alpha*con.deltaWeight : 0);
      else
        {
         con.mt = b1 * con.mt + (1 - b1) * gradient;
         con.vt = (float)(b2 * con.vt + (1 - b2) * pow(gradient, 2) + 0.00000001);
         con.weight += con.deltaWeight = (float)(lt * con.mt / sqrt(con.vt));
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNeuron::sumDOW(CLayer *&nextLayer)
  {
   float sum = 0.0;
   int total = nextLayer.Total() - 1;
   for(int n = 0; n < total; n++)
     {
      CConnection *con = Connections.At(n);
      if(CheckPointer(con) == POINTER_INVALID)
         continue;
      float weight = con.weight;
      if(weight != 0)
        {
         CNeuron *neuron = nextLayer.At(n);
         sum += weight * neuron.gradient;
        }
     }
   return sum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuron::calcHiddenGradients(CLayer *&nextLayer)
  {
   float targetVal = sumDOW(nextLayer) + outputVal;
   return calcOutputGradients(targetVal);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuron::calcOutputGradients(float targetVal)
  {
   float delta = (targetVal > 1 ? 1 : targetVal < -1 ? -1 : targetVal) - outputVal;
   gradient = (delta != 0 ? delta * activationFunctionDerivative(outputVal) : 0);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuron::feedForward(CLayer *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID || prevLayer.Type() != defLayer)
      return false;
//---
   prevVal = outputVal;
   float sum = 0.0;
   int total = prevLayer.Total();
   for(int n = 0; n < total && !IsStopped(); n++)
     {
      CNeuron *temp = prevLayer.At(n);
      float val = temp.getOutputVal();
      if(val != 0)
        {
         CConnection *con = temp.Connections.At(m_myIndex);
         if(CheckPointer(con) == POINTER_INVALID)
            continue;
         sum += val * con.weight;
        }
     }
   outputVal = activationFunction(MathMin(MathMax(sum, -18), 18));
//---
   return true;
  }
//+------------------------------------------------------------------+
///\class COpenCLMy
/// Class for working with OpenCL
//+------------------------------------------------------------------+
class COpenCLMy   :  public COpenCL
  {
public:
   /** Constructor */
                     COpenCLMy(void)   {};
   /** Destructor */~COpenCLMy(void)   {};
   template<typename T>
   int               AddBufferFromArray(T &data[], const uint data_array_offset, const uint data_array_count, const uint flags);
   ///< Method for creating OpenCL buffer from array.@param data[] Array of data.@param data_array_offset Offset of data in array.@param data_array_count Number of data items in array.@param flags Buffer's properties (CL_MEM_READ_WRITE, CL_MEM_WRITE_ONLY, CL_MEM_READ_ONLY, CL_MEM_ALLOC_HOST_PTR)
   int               AddBuffer(uint size_in_bytes, const uint flags);
   /// @return Index of buffer.
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLayer: public CArrayObj
  {
private:
   uint              iOutputs;                                 ///< Number of output connections from 1 neuron to neurons in next layer.
   int               iFileHandle;                              ///< File handle for download result of previous study.
   COpenCLMy         *OpenCL;                                   ///< Class for working with OpenCL

public:
   /** Constructor */
                     CLayer(uint outputs = 0, int handle = INVALID_HANDLE, COpenCLMy *OpenCL = NULL);
   ///< @param[in] outputs Number of output connections from 1 neuron to neurons in next layer @param[in] handle File handle for download result of previous study @param[in] OpenCL Pointer to class for working with OpenCL
   /** Destructor */~CLayer(void) {};
   //---
   virtual bool      CreateElement(int const index);           ///< Method for creating new element in layer
   virtual void      IncreaseTotal()   {  m_data_total++;   }  ///< Method for increase number of items in layer
   virtual int       Type(void)  const { return defLayer; }    ///< Identificator of class.@return Type of class
   virtual bool      Load(const int file_handle);              ///< Load method @param[in] file_handle handle of file @return logical result of operation
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLayer::CreateElement(int index)
  {
   if(index >= m_data_max)
      return false;
//---
   bool result = false;
   CNeuronBase *temp = NULL;
   CNeuronProof *temp_p = NULL;
   CNeuronBaseOCL *temp_ocl = NULL;
   CNeuronConvOCL *temp_con_ocl = NULL;
   CNeuronAttentionOCL *temp_at_ocl = NULL;
   CNeuronMLMHAttentionOCL *temp_mlat_ocl = NULL;
   CNeuronDropoutOCL *temp_drop_ocl = NULL;
   CNeuronBatchNormOCL *temp_batch_ocl = NULL;
   CVAE *vae = NULL;
   CNeuronLSTMOCL *lstm = NULL;
   if(iFileHandle <= 0)
     {
      temp = new CNeuron();
      if(CheckPointer(temp) == POINTER_INVALID || !temp.Init(iOutputs, index, SGD))
         return false;
      result = true;
     }
   else
     {
      int type = FileReadInteger(iFileHandle);
      switch(type)
        {
         case  defNeuron:
            temp = new CNeuron();
            if(CheckPointer(temp) == POINTER_INVALID)
               result = false;
            result = temp.Init(iOutputs, index, ADAM);
            break;
         case  defNeuronProof:
            temp_p = new CNeuronProof();
            if(CheckPointer(temp_p) == POINTER_INVALID)
               result = false;
            if(temp_p.Init(iOutputs, index, 1, 1, 1, ADAM))
              {
               temp = temp_p;
               result = true;
              }
            break;
         case  defNeuronConv:
            temp_p = new CNeuronConv();
            if(CheckPointer(temp_p) == POINTER_INVALID)
               result = false;
            if(temp_p.Init(iOutputs, index, 1, 1, 1, ADAM))
              {
               temp = temp_p;
               result = true;
              }
            break;
         case  defNeuronLSTM:
            temp_p = new CNeuronLSTM();
            if(CheckPointer(temp_p) == POINTER_INVALID)
               result = false;
            if(temp_p.Init(iOutputs, index, 1, 1, 1, ADAM))
              {
               temp = temp_p;
               result = true;
              }
            break;
         case  defNeuronBaseOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_ocl = new CNeuronBaseOCL();
            if(CheckPointer(temp_ocl) == POINTER_INVALID)
               result = false;
            if(temp_ocl.Init(iOutputs, index, OpenCL, 1, ADAM, 1))
              {
               m_data[index] = temp_ocl;
               return true;
              }
            break;
         case  defNeuronConvOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_con_ocl = new CNeuronConvOCL();
            if(CheckPointer(temp_con_ocl) == POINTER_INVALID)
               result = false;
            if(temp_con_ocl.Init(iOutputs, index, OpenCL, 1, 1, 1, 1, ADAM, 1))
              {
               m_data[index] = temp_con_ocl;
               return true;
              }
            break;
         case  defNeuronAttentionOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_at_ocl = new CNeuronAttentionOCL();
            if(CheckPointer(temp_at_ocl) == POINTER_INVALID)
               result = false;
            if(temp_at_ocl.Init(iOutputs, index, OpenCL, 1, 1, ADAM, 1))
              {
               m_data[index] = temp_at_ocl;
               return true;
              }
            break;
         case  defNeuronMHAttentionOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_at_ocl = new CNeuronMHAttentionOCL();
            if(CheckPointer(temp_at_ocl) == POINTER_INVALID)
               result = false;
            if(temp_at_ocl.Init(iOutputs, index, OpenCL, 1, 1, ADAM, 1))
              {
               m_data[index] = temp_at_ocl;
               return true;
              }
            break;
         case  defNeuronMLMHAttentionOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_mlat_ocl = new CNeuronMLMHAttentionOCL();
            if(CheckPointer(temp_mlat_ocl) == POINTER_INVALID)
               result = false;
            if(temp_mlat_ocl.Init(iOutputs, index, OpenCL, 1, 1, 1, 1, 0, ADAM, 1))
              {
               m_data[index] = temp_mlat_ocl;
               return true;
              }
            break;
         case  defNeuronDropoutOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_drop_ocl = new CNeuronDropoutOCL();
            if(CheckPointer(temp_drop_ocl) == POINTER_INVALID)
               result = false;
            if(temp_drop_ocl.Init(iOutputs, index, OpenCL, 1.0f, 0.1f, ADAM, 1))
              {
               m_data[index] = temp_drop_ocl;
               return true;
              }
            break;
         case  defNeuronBatchNormOCL:
            if(CheckPointer(OpenCL) == POINTER_INVALID)
               return false;
            temp_batch_ocl = new CNeuronBatchNormOCL();
            if(CheckPointer(temp_batch_ocl) == POINTER_INVALID)
               result = false;
            if(temp_batch_ocl.Init(iOutputs, index, OpenCL, 1, 1, ADAM))
              {
               m_data[index] = temp_batch_ocl;
               return true;
              }
            break;
         case  defNeuronVAEOCL:
            if(!OpenCL)
               return false;
            vae = new CVAE();
            if(!vae)
               result = false;
            if(vae.Init(iOutputs, index, OpenCL, 1, ADAM, 1))
              {
               m_data[index] = vae;
               return true;
              }
            break;
         case  defNeuronLSTMOCL:
            if(!OpenCL)
               return false;
            lstm = new CNeuronLSTMOCL();
            if(!lstm)
               result = false;
            if(lstm.Init(iOutputs, index, OpenCL, 1, ADAM, 1))
              {
               m_data[index] = lstm;
               return true;
              }
            break;
         default:
            result = false;
            break;
        }
     }
   if(result)
      m_data[index] = temp;
//---
   return (result);
  }
//+------------------------------------------------------------------+
///\class CArrayLayer
/// Class of layers collection in Neural Net.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para53">the link.</A>
//+------------------------------------------------------------------+
class CArrayLayer  :    public CArrayObj
  {
public:
   /** Constructor */
                     CArrayLayer(void) {};
   /** Destructor */~CArrayLayer(void) {};
   //---
   virtual bool      CreateElement(uint neurons,  uint outputs);  ///< Method for creating new element
   virtual int       Type(void)  const { return defArrayLayer; }  ///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CArrayLayer::CreateElement(uint neurons,  uint outputs)
  {
   if(neurons <= 0)
      return false;
//---
   CLayer *layer = new CLayer(outputs);
   if(!CheckPointer(layer) != POINTER_INVALID)
      return false;
//---
   if(!layer.Reserve(neurons + 1))
      return false;
   for(uint i = 0; i <= neurons; i++)
     {
      if(!layer.CreateElement(i))
         return false;
      layer.IncreaseTotal();
     }
//---
   return (Add(layer));
  }
//+------------------------------------------------------------------+
///\class CNeuronProof
/// Class of pooling layer
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8234#para42">the link.</A>
//+------------------------------------------------------------------+
class CNeuronProof : public CNeuronBase
  {
protected:
   CLayer            *OutputLayer;                                      ///< Layer of output data. Used for connection with next layer.
   int               iWindow;                                           ///< Input window size
   int               iStep;                                             ///< Size of step

   virtual bool      feedForward(CLayer *prevLayer);                    ///< Feed Forward method.@param prevLayer Pointer to previos layer.
   virtual bool      calcHiddenGradients(CLayer *&nextLayer);           ///< Method to transfer gradient to previous layer. @param nextLayer Pointer to next layer.

public:
   /** Constructor */
                     CNeuronProof(void) {};
   /** Destructor */~CNeuronProof(void);
   virtual bool      Init(uint numOutputs, uint myIndex, int window, int step, int units_count, ENUM_OPTIMIZATION optimization_type);
   ///< Method of initialization class.@param numOutputs Number of connections to next layer.@param myIndex Index of neuron in layer.@param window Size of input window @param step Step size.@param units_countNumber of neurons.@param optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   //---
   virtual CLayer    *getOutputLayer(void)  { return OutputLayer;  }    ///< Method for getting a pointer to the resulting neural layer. Not used in fully connected neural networks.@return Pointer to layer.
   virtual bool      calcInputGradients(CLayer *prevLayer);             ///< Method to transfer gradients to previous layer @param[in] prevLayer Pointer to previous layer.
   virtual bool      calcInputGradients(CNeuronBase *prevNeuron, uint index); ///< Method to transfer gradients to neuron in previous layer @param[in] prevNeuron Pointer to neuron.@param[in] index Index of neuron in previous layer
   //--- methods for working with files
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual int       Type(void)   const   {  return defNeuronProof;   }///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
///\class CNeuronConv
/// Class of convolution layer
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8234#para43">the link.</A>
//+------------------------------------------------------------------+
class CNeuronConv  :  public CNeuronProof
  {
protected:
   float             param;   //PReLU param
   virtual bool      feedForward(CLayer *prevLayer);                    ///< Feed Forward method.@param prevLayer Pointer to previos layer.
   virtual bool      calcHiddenGradients(CLayer *&nextLayer);           ///< Method to transfer gradient to previous layer. @param nextLayer Pointer to next layer.
   virtual float     activationFunction(float x);                      ///< Method to calculate activation function.@param x Input data. @return Result of activation function.
   virtual bool      updateInputWeights(CLayer *&prevLayer);            ///< Method for updating weights.@param prevLayer Pointer to previos layer.
public:
   /** Constructor */
                     CNeuronConv() :   param((float)0.01) { };
   /** Destructor */~CNeuronConv(void)             { };
   //---
   virtual bool      calcInputGradients(CLayer *prevLayer);                  ///< Method to transfer gradients to previous layer @param[in] prevLayer Pointer to previous layer.
   virtual bool      calcInputGradients(CNeuronBase *prevNeuron, uint index);///< Method to transfer gradients to neuron in previous layer @param[in] prevNeuron Pointer to neuron.@param[in] index Index of neuron in previous layer
   virtual float     activationFunctionDerivative(float x);                 ///< Calculate derivative of activation function.@param[in] x Input data@return Derivative
   virtual int       Type(void)   const   {  return defNeuronConv;   }///< Identificator of class.@return Type of class
   //--- methods for working with files
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::feedForward(CObject *&SourceObject)
  {
   bool result = false;
//---
   if(CheckPointer(SourceObject) == POINTER_INVALID)
      return result;
//---
   CLayer *temp_l;
   CNeuronProof *temp_n;
   switch(SourceObject.Type())
     {
      case defLayer:
         temp_l = SourceObject;
         result = feedForward(temp_l);
         break;
      case defNeuronConv:
      case defNeuronProof:
      case defNeuronLSTM:
         temp_n = SourceObject;
         result = feedForward(temp_n.getOutputLayer());
         break;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::updateInputWeights(CObject *&SourceObject)
  {
   bool result = false;
//---
   if(CheckPointer(SourceObject) == POINTER_INVALID)
      return result;
//---
   CLayer *temp_l;
   CNeuronProof *temp_n;
   switch(SourceObject.Type())
     {
      case defLayer:
         temp_l = SourceObject;
         result = updateInputWeights(temp_l);
         break;
      case defNeuronConv:
      case defNeuronProof:
      case defNeuronLSTM:
         temp_n = SourceObject;
         temp_l = temp_n.getOutputLayer();
         result = updateInputWeights(temp_l);
         break;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::feedForward(CLayer *prevLayer)
  {
   bool result = false;
//---
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return result;
//---
   int total = prevLayer.Total() - iWindow + 1;
   CNeuron *temp;
   CConnection *con;
   result = true;
   for(int i = 0; (i < total && result); i += iStep)
     {
      float sum = 0;
      for(int j = 0; (j < iWindow && result); j++)
        {
         temp = prevLayer.At(i + j);
         con = Connections.At(j);
         if(CheckPointer(temp) == POINTER_INVALID || CheckPointer(con) == POINTER_INVALID)
            return false;
         float val = temp.getOutputVal();
         sum += val * con.weight;
        }
      temp = OutputLayer.At(i / iStep);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      temp.setOutputVal(activationFunction(sum));
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNeuronConv::activationFunction(float x)
  {
   if(x >= 0)
      return x;
   return param * x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::calcHiddenGradients(CObject *&TargetObject)
  {
   bool result = false;
//---
   if(CheckPointer(TargetObject) == POINTER_INVALID)
      return result;
//---
   CLayer *temp_l;
   CNeuronProof *temp_n;
   switch(TargetObject.Type())
     {
      case defLayer:
         temp_l = TargetObject;
         result = calcHiddenGradients(temp_l);
         break;
      case defNeuronConv:
      case defNeuronProof:
      case defNeuronLSTM:
         switch(Type())
           {
            case defNeuron:
               temp_n = TargetObject;
               result = temp_n.calcInputGradients(GetPointer(this), m_myIndex);
               break;
            case defNeuronLSTM:
               temp_n = TargetObject;
               temp_l = getOutputLayer();
               if(!temp_n.calcInputGradients(temp_l))
                 {
                  result = false;
                  break;
                 }
               result = calcHiddenGradients(temp_l);
               break;
            default:
               //temp_n=GetPointer(this);
               temp_l =/*temp_n*/getOutputLayer();
               temp_n = TargetObject;
               result = temp_n.calcInputGradients(temp_l);
               break;
           }
         break;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::calcHiddenGradients(CLayer *&nextLayer)
  {
   if(CheckPointer(nextLayer) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID || OutputLayer.Total() <= 0)
      return false;
//---
   gradient = 0;
   int total = OutputLayer.Total();
   CNeuron *temp;
   for(int i = 0; i < total; i++)
     {
      temp = OutputLayer.At(i);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      temp.setGradient(temp.sumDOW(nextLayer)*activationFunctionDerivative(temp.getOutputVal()));
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNeuronConv::activationFunctionDerivative(float x)
  {
   if(x >= 0)
      return 1;
   return param;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::updateInputWeights(CLayer *&prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID)
      return false;
//---
   CConnection *con;
   float lt = (float)(eta * sqrt(1 - pow(b2, t)) / (1 - pow(b1, t)));
   for(int n = 0; n < iWindow && !IsStopped(); n++)
     {
      con = Connections.At(n);
      if(CheckPointer(con) == POINTER_INVALID)
         continue;
      float delta = 0;
      int total_i = OutputLayer.Total();
      CNeuron *prev, *out;
      for(int i = 0; i < total_i; i++)
        {
         prev = prevLayer.At(n * iStep + i);
         out = OutputLayer.At(total_i - i - 1);
         if(CheckPointer(prev) == POINTER_INVALID || CheckPointer(out) == POINTER_INVALID)
            continue;
         delta += prev.getOutputVal() * out.getGradient();
        }
      if(optimization == SGD)
         con.weight += con.deltaWeight = (delta != 0 ? eta*delta : 0) + (con.deltaWeight != 0 ? alpha*con.deltaWeight : 0);
      else
        {
         con.mt = b1 * con.mt + (1 - b1) * delta;
         con.vt = (float)(b2 * con.vt + (1 - b2) * pow(delta, 2) + 0.00000001);
         con.weight += con.deltaWeight = (float)(lt * con.mt / sqrt(con.vt));
         t++;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::Init(uint numOutputs, uint myIndex, int window, int step, int units_count, ENUM_OPTIMIZATION optimization_type)
  {
   iWindow = window;
   iStep = step;
   if(!CNeuronBase::Init(window, myIndex, optimization_type))
      return false;
   OutputLayer = new CLayer(numOutputs);
   if(CheckPointer(OutputLayer) == POINTER_INVALID)
      return false;
   if(OutputLayer.Reserve(units_count))
      for(int i = 0; i < units_count; i++)
        {
         if(!OutputLayer.CreateElement(i))
            return false;
         OutputLayer.IncreaseTotal();
        }
//---
   if(Type() == defNeuronProof)
     {
      if(CheckPointer(Connections) != POINTER_INVALID)
         Connections.Clear();
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronProof::~CNeuronProof(void)
  {
   if(CheckPointer(OutputLayer) != POINTER_INVALID)
      delete OutputLayer;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::feedForward(CLayer *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
   int total = prevLayer.Total() - iWindow + 1;
   CNeuron *temp;
   for(int i = 0; i <= total; i += iStep)
     {
      float sum = 0;
      for(int j = 0; j < iWindow; j++)
        {
         temp = prevLayer.At(i + j);
         if(CheckPointer(temp) == POINTER_INVALID)
            continue;
         sum += temp.getOutputVal();
        }
      temp = OutputLayer.At(i / iStep);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      temp.setOutputVal(sum / iWindow);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::calcHiddenGradients(CLayer *&nextLayer)
  {
   if(CheckPointer(nextLayer) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID || OutputLayer.Total() <= 0)
      return false;
//---
   gradient = 0;
   int total = OutputLayer.Total();
   CNeuron *temp;
   for(int i = 0; i < total; i++)
     {
      temp = OutputLayer.At(i);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      temp.setGradient(temp.sumDOW(nextLayer));
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::calcInputGradients(CLayer *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID  || CheckPointer(prevLayer.At(0)) == POINTER_INVALID)
      return false;
//---
   if(prevLayer.At(0).Type() != defNeuron)
     {
      CNeuronProof *temp = prevLayer.At(m_myIndex);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      prevLayer = temp.getOutputLayer();
      if(CheckPointer(prevLayer) == POINTER_INVALID)
         return false;
     }
//---
   CNeuronBase *prevNeuron, *outputNeuron;
   int total = prevLayer.Total();
   for(int i = 0; i < total; i++)
     {
      prevNeuron = prevLayer.At(i);
      if(CheckPointer(prevNeuron) == POINTER_INVALID)
         continue;
      float prev_gradient = 0;
      int start = i - iWindow + iStep;
      start = (start - start % iStep) / iStep;
      float stop = (float)((i - i % iStep) / iStep + 1);
      for(int out = (int)fmax(0, start); out < (int)fmin(OutputLayer.Total(), stop); out++)
        {
         outputNeuron = OutputLayer.At(out);
         if(CheckPointer(outputNeuron) == POINTER_INVALID)
            continue;
         prev_gradient += outputNeuron.getGradient() / iWindow;
        }
      prevNeuron.setGradient(prev_gradient);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::calcInputGradients(CNeuronBase *prevNeuron, uint index)
  {
   if(CheckPointer(prevNeuron) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID)
      return false;
//---
   if(prevNeuron.Type() != defNeuron)
     {
      CNeuronProof *temp = prevNeuron;
      return calcInputGradients(temp.getOutputLayer());
     }
//---
   CNeuronBase *outputNeuron;
   float prev_gradient = 0;
   int start = (int)index - iWindow + iStep;
   start = (start - start % iStep) / iStep;
   float stop = (float)((index - index % iStep) / iStep + 1);
   for(int out = (int)fmax(0, start); out < (int)fmin(OutputLayer.Total(), stop); out++)
     {
      outputNeuron = OutputLayer.At(out);
      if(CheckPointer(outputNeuron) == POINTER_INVALID)
         continue;
      prev_gradient += outputNeuron.getGradient() / iWindow;
     }
   prevNeuron.setGradient(prev_gradient);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::calcInputGradients(CLayer *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID)
      return false;
//---
   if(prevLayer.At(0).Type() != defNeuron)
     {
      CNeuronProof *temp = prevLayer.At(m_myIndex);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      prevLayer = temp.getOutputLayer();
      if(CheckPointer(prevLayer) == POINTER_INVALID)
         return false;
     }
//---
   CNeuronBase *prevNeuron, *outputNeuron;
   CConnection *con;
   int total = prevLayer.Total();
   for(int i = 0; i < total; i++)
     {
      prevNeuron = prevLayer.At(i);
      if(CheckPointer(prevNeuron) == POINTER_INVALID)
         continue;
      float prev_gradient = 0;
      int start = i - iWindow + iStep;
      start = (start - start % iStep) / iStep;
      float stop = (float)((i - i % iStep) / iStep + 1);
      for(int out = (int)fmax(0, start); out < (int)fmin(OutputLayer.Total(), stop); out++)
        {
         outputNeuron = OutputLayer.At(out);
         int c = ((int)fmin(OutputLayer.Total(), stop) - out - 1) * iStep + i % iStep;
         con = Connections.At(c);
         if(CheckPointer(outputNeuron) == POINTER_INVALID || CheckPointer(con) == POINTER_INVALID)
            continue;
         prev_gradient += outputNeuron.getGradient() * prevNeuron.activationFunctionDerivative(prevNeuron.getOutputVal()) * con.weight;
        }
      prevNeuron.setGradient(prev_gradient);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::calcInputGradients(CNeuronBase *prevNeuron, uint index)
  {
   if(CheckPointer(prevNeuron) == POINTER_INVALID || CheckPointer(OutputLayer) == POINTER_INVALID)
      return false;
//---
   if(prevNeuron.Type() != defNeuron)
     {
      CNeuronProof *temp = prevNeuron;
      return calcInputGradients(temp.getOutputLayer());
     }
//---
   CNeuronBase *outputNeuron;
   CConnection *con;
   float prev_gradient = 0;
   int start = (int)index - iWindow + iStep;
   start = (start - start % iStep) / iStep;
   float stop = (float)((index - index % iStep) / iStep + 1);
   for(int out = (int)fmax(0, start); out < (int)fmin(OutputLayer.Total(), stop); out++)
     {
      outputNeuron = OutputLayer.At(out);
      int c = (int)(((int)fmin(OutputLayer.Total(), stop) - out - 1) * iStep + index % iStep);
      con = Connections.At(c);
      if(CheckPointer(outputNeuron) == POINTER_INVALID || CheckPointer(con) == POINTER_INVALID)
         continue;
      prev_gradient += outputNeuron.getGradient() * activationFunctionDerivative(outputNeuron.getOutputVal()) * con.weight;
     }
   prevNeuron.setGradient(prev_gradient);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::Save(int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
   if(FileWriteInteger(file_handle, Type()) < INT_VALUE)
      return false;
//---
   if(FileWriteInteger(file_handle, (int)activation, INT_VALUE) < INT_VALUE)
      return false;
//---
   if(FileWriteInteger(file_handle, (int)optimization, INT_VALUE) < INT_VALUE)
      return false;
//---
   if(FileWriteInteger(file_handle, t, INT_VALUE) < INT_VALUE)
      return false;
//---
   return Connections.Save(file_handle);
  }
//+------------------------------------------------------------------+
///\class CLayerDescription
/// Class of layer decription. Used to describe the structure of a neural network from the main program.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8234#para44">the link.</A>
//+------------------------------------------------------------------+
class CLayerDescription    :  public CObject
  {
public:
   /** Constructor */
                     CLayerDescription(void);
   /** Destructor */~CLayerDescription(void) {};
   //---
   int               type;          ///< Type of neurons in layer (\ref ObjectTypes)
   int               count;         ///< Number of neurons
   int               window;        ///< Size of input window
   int               window_out;    ///< Size of output window
   int               step;          ///< Step size
   int               layers;        ///< Layers count
   int               batch;         ///< Batch Size
   ENUM_ACTIVATION   activation;    ///< Type of activation function (#ENUM_ACTIVATION)
   ENUM_OPTIMIZATION optimization;  ///< Type of optimization method (#ENUM_OPTIMIZATION)
   float             probability;   ///< Probability of neurons shutdown, only Dropout used
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription::CLayerDescription(void)   :  type(defNeuron),
   count(0),
   window(1),
   step(1),
   layers(1),
   activation(TANH),
   optimization(ADAM),
   probability((float)0.1),
   batch(100)
  {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBufferFloat;
//+------------------------------------------------------------------+
///\class CNet
/// The main class of the neural network. Contains basic methods for the functioning of a neural network.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/7447#para53">the link.</A>
//+------------------------------------------------------------------+
class CNet
  {
protected:
   bool              backPropOCL(CArrayFloat *targetVals, bool layer_by_layer = true);              ///< Back propagation method for GPU calculation. @param[in] targetVals Target values
   int               backPropCount;
   CArrayLayer       *layers;                                  ///< Array of layers
   COpenCLMy         *opencl;                                  ///< Class for working with OpenCL

public:
   /** Constructor */
                     CNet(void)  {Create(NULL);}
                     CNet(CArrayObj *Description)  { Create(Description); }
   void              Create(CArrayObj *Description);
   /** Destructor */~CNet(void);
   bool              feedForward(CArrayFloat *inputVals, int window = 1, bool tem = true); ///< Feed Forward method.@param[in] prevLayer Pointer to previos layer. @param[in] window Window of input data. @param[in] tem Use Time Embedding.
   bool              backProp(CArrayFloat *targetVals);                   ///< Back propagation method. @param[in] targetVals Target values
   void              getResults(CBufferFloat *&resultVals);                ///< Method to get results of feed forward process.@param[out] resultVals Array of result values
   float             getRecentAverageError()  { return recentAverageError; } ///< Method to check quality of study. @return Average error
   bool              Save(string file_name, float error, float undefine, float forecast, datetime time, bool common = true);
   ///< Save method. @param[in] file_name File name to save @param[in] error Average error @param[in] undefine Undefined percent @param[in] Foecast percent @param[in] time Last study time @param[in] common Common flag
   bool              Load(string file_name, float &error, float &undefine, float &forecast, datetime &time, bool common = true);
   ///< Load method. @param[in] file_name File name to save @param[out] error Average error @param[out] undefine Undefined percent @param[out] Foecast percent @param[out] time Last study time @param[in] common Common flag
   //---
   static float      recentAverageSmoothingFactor;             ///< Smoothing factor of average error
   virtual int       Type(void)   const   {  return defNet;   }///< Identificator of class.@return Type of class
   virtual bool      TrainMode(bool flag);                     ///< Set Training Mode Flag
   virtual bool      GetLayerOutput(uint layer, CBufferFloat *&result); ///< Retutn Output data of layer. @param[in] layer Number of layer @param[out] return Buffer with data

private:
   float             recentAverageError;                       ///< Average error
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNet::recentAverageSmoothingFactor = 10000.0; // Number of training samples to average over
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNet::Create(CArrayObj *Description)
  {
   recentAverageError = 0;
   backPropCount = 0;
   if(CheckPointer(Description) == POINTER_INVALID)
      return;
//---
   int total = Description.Total();
   if(total <= 0)
      return;
//---
   layers = new CArrayLayer();
   if(CheckPointer(layers) == POINTER_INVALID)
      return;
//---
   CLayer *temp;
   CLayerDescription *desc = NULL, *next = NULL, *prev = NULL;
   CNeuronBase *neuron = NULL;
   CNeuronProof *neuron_p = NULL;
   int output_count = 0;
   int temp_count = 0;
//---
   next = Description.At(1);
   if(next.type == defNeuron || next.type >= defNeuronBaseOCL)
     {
      opencl = new COpenCLMy();
      if(CheckPointer(opencl) != POINTER_INVALID && !opencl.Initialize(cl_program, true))
         delete opencl;
     }
   else
     {
      if(CheckPointer(opencl) != POINTER_INVALID)
         delete opencl;
     }
//---
   for(int i = 0; i < total; i++)
     {
      prev = desc;
      desc = Description.At(i);
      if((i + 1) < total)
        {
         next = Description.At(i + 1);
         if(CheckPointer(next) == POINTER_INVALID)
            return;
        }
      else
         next = NULL;
      int outputs = (next == NULL || (next.type != defNeuron && next.type != defNeuronBaseOCL) ? 0 : next.count);
      temp = new CLayer(outputs);
      int neurons = (desc.count + (desc.type == defNeuron || desc.type == defNeuronBaseOCL ? 1 : 0));
      if(CheckPointer(opencl) != POINTER_INVALID)
        {
         CNeuronBaseOCL *neuron_ocl = NULL;
         CNeuronConvOCL *neuron_conv_ocl = NULL;
         CNeuronProofOCL *neuron_proof_ocl = NULL;
         CNeuronAttentionOCL *neuron_attention_ocl = NULL;
         CNeuronMLMHAttentionOCL *neuron_mlattention_ocl = NULL;
         CNeuronDropoutOCL *dropout = NULL;
         CNeuronBatchNormOCL *batch = NULL;
         CVAE *vae = NULL;
         CNeuronLSTMOCL *lstm = NULL;
         switch(desc.type)
           {
            case defNeuron:
            case defNeuronBaseOCL:
               neuron_ocl = new CNeuronBaseOCL();
               if(CheckPointer(neuron_ocl) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!neuron_ocl.Init(outputs, 0, opencl, desc.count, desc.optimization, desc.batch))
                 {
                  delete neuron_ocl;
                  delete temp;
                  return;
                 }
               neuron_ocl.SetActivationFunction(desc.activation);
               if(!temp.Add(neuron_ocl))
                 {
                  delete neuron_ocl;
                  delete temp;
                  return;
                 }
               neuron_ocl = NULL;
               break;
            //---
            case defNeuronConvOCL:
               neuron_conv_ocl = new CNeuronConvOCL();
               if(CheckPointer(neuron_conv_ocl) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!neuron_conv_ocl.Init(outputs, 0, opencl, desc.window, desc.step, desc.window_out, desc.count, desc.optimization, desc.batch))
                 {
                  delete neuron_conv_ocl;
                  delete temp;
                  return;
                 }
               neuron_conv_ocl.SetActivationFunction(desc.activation);
               if(!temp.Add(neuron_conv_ocl))
                 {
                  delete neuron_conv_ocl;
                  delete temp;
                  return;
                 }
               neuron_conv_ocl = NULL;
               break;
            //---
            case defNeuronProofOCL:
               neuron_proof_ocl = new CNeuronProofOCL();
               if(!neuron_proof_ocl)
                 {
                  delete temp;
                  return;
                 }
               if(!neuron_proof_ocl.Init(outputs, 0, opencl, desc.window, desc.step, desc.count, desc.optimization, desc.batch))
                 {
                  delete neuron_proof_ocl;
                  delete temp;
                  return;
                 }
               neuron_proof_ocl.SetActivationFunction(desc.activation);
               if(!temp.Add(neuron_proof_ocl))
                 {
                  delete neuron_proof_ocl;
                  delete temp;
                  return;
                 }
               neuron_proof_ocl = NULL;
               break;
            //---
            case defNeuronAttentionOCL:
               neuron_attention_ocl = new CNeuronAttentionOCL();
               if(CheckPointer(neuron_attention_ocl) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!neuron_attention_ocl.Init(outputs, 0, opencl, desc.window, desc.count, desc.optimization, desc.batch))
                 {
                  delete neuron_attention_ocl;
                  delete temp;
                  return;
                 }
               neuron_attention_ocl.SetActivationFunction(desc.activation);
               if(!temp.Add(neuron_attention_ocl))
                 {
                  delete neuron_attention_ocl;
                  delete temp;
                  return;
                 }
               neuron_attention_ocl = NULL;
               break;
            //---
            case defNeuronMHAttentionOCL:
               neuron_attention_ocl = new CNeuronMHAttentionOCL();
               if(CheckPointer(neuron_attention_ocl) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!neuron_attention_ocl.Init(outputs, 0, opencl, desc.window, desc.count, desc.optimization, desc.batch))
                 {
                  delete neuron_attention_ocl;
                  delete temp;
                  return;
                 }
               neuron_attention_ocl.SetActivationFunction(desc.activation);
               if(!temp.Add(neuron_attention_ocl))
                 {
                  delete neuron_attention_ocl;
                  delete temp;
                  return;
                 }
               neuron_attention_ocl = NULL;
               break;
            //---
            case defNeuronMLMHAttentionOCL:
               neuron_mlattention_ocl = new CNeuronMLMHAttentionOCL();
               if(CheckPointer(neuron_mlattention_ocl) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!neuron_mlattention_ocl.Init(outputs, 0, opencl, desc.window, desc.window_out, desc.step, desc.count, desc.layers, desc.optimization, desc.batch))
                 {
                  delete neuron_mlattention_ocl;
                  delete temp;
                  return;
                 }
               neuron_mlattention_ocl.SetActivationFunction(desc.activation);
               if(!temp.Add(neuron_mlattention_ocl))
                 {
                  delete neuron_mlattention_ocl;
                  delete temp;
                  return;
                 }
               neuron_mlattention_ocl = NULL;
               break;
            //---
            case defNeuronDropoutOCL:
               dropout = new CNeuronDropoutOCL();
               if(CheckPointer(dropout) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!dropout.Init(outputs, 0, opencl, desc.count, desc.probability, desc.optimization, desc.batch))
                 {
                  delete dropout;
                  delete temp;
                  return;
                 }
               if(!temp.Add(dropout))
                 {
                  delete dropout;
                  delete temp;
                  return;
                 }
               dropout = NULL;
               break;
            //---
            case defNeuronBatchNormOCL:
               batch = new CNeuronBatchNormOCL();
               if(CheckPointer(batch) == POINTER_INVALID)
                 {
                  delete temp;
                  return;
                 }
               if(!batch.Init(outputs, 0, opencl, desc.count, desc.batch, desc.optimization))
                 {
                  delete batch;
                  delete temp;
                  return;
                 }
               batch.SetActivationFunction(desc.activation);
               if(!temp.Add(batch))
                 {
                  delete batch;
                  delete temp;
                  return;
                 }
               batch = NULL;
               break;
            //---
            case defNeuronVAEOCL:
               vae = new CVAE();
               if(!vae)
                 {
                  delete temp;
                  return;
                 }
               if(!vae.Init(outputs, 0, opencl, desc.count, desc.optimization, desc.batch))
                 {
                  delete vae;
                  delete temp;
                  return;
                 }
               if(!temp.Add(vae))
                 {
                  delete vae;
                  delete temp;
                  return;
                 }
               vae = NULL;
               break;
            case defNeuronLSTMOCL:
               lstm = new CNeuronLSTMOCL();
               if(!lstm)
                 {
                  delete temp;
                  return;
                 }
               if(!lstm.Init(outputs, 0, opencl, desc.count, desc.optimization, desc.batch))
                 {
                  delete lstm;
                  delete temp;
                  return;
                 }
               if(!!prev)
                  if(!lstm.SetInputs(prev.count))
                    {
                     delete lstm;
                     delete temp;
                     return;
                    }
               if(!temp.Add(lstm))
                 {
                  delete lstm;
                  delete temp;
                  return;
                 }
               lstm = NULL;
               break;
            default:
               return;
               break;
           }
        }
      else
         for(int n = 0; n < neurons; n++)
           {
            switch(desc.type)
              {
               case defNeuron:
                  neuron = new CNeuron();
                  if(CheckPointer(neuron) == POINTER_INVALID)
                    {
                     delete temp;
                     delete layers;
                     return;
                    }
                  neuron.Init(outputs, n, desc.optimization);
                  neuron.SetActivationFunction(desc.activation);
                  break;
               case defNeuronConv:
                  neuron_p = new CNeuronConv();
                  if(CheckPointer(neuron_p) == POINTER_INVALID)
                    {
                     delete temp;
                     delete layers;
                     return;
                    }
                  if(CheckPointer(prev) != POINTER_INVALID)
                    {
                     if(prev.type == defNeuron)
                       {
                        temp_count = (int)((prev.count - desc.window) % desc.step);
                        output_count = (int)((prev.count - desc.window - temp_count) / desc.step + (temp_count == 0 ? 1 : 2));
                       }
                     else
                        if(n == 0)
                          {
                           temp_count = (int)((output_count - desc.window) % desc.step);
                           output_count = (int)((output_count - desc.window - temp_count) / desc.step + (temp_count == 0 ? 1 : 2));
                          }
                    }
                  if(neuron_p.Init(outputs, n, desc.window, desc.step, output_count, desc.optimization))
                     neuron = neuron_p;
                  break;
               case defNeuronProof:
                  neuron_p = new CNeuronProof();
                  if(CheckPointer(neuron_p) == POINTER_INVALID)
                    {
                     delete temp;
                     delete layers;
                     return;
                    }
                  if(CheckPointer(prev) != POINTER_INVALID)
                    {
                     if(prev.type == defNeuron)
                       {
                        temp_count = (int)((prev.count - desc.window) % desc.step);
                        output_count = (int)((prev.count - desc.window - temp_count) / desc.step + (temp_count == 0 ? 1 : 2));
                       }
                     else
                        if(n == 0)
                          {
                           temp_count = (int)((output_count - desc.window) % desc.step);
                           output_count = (int)((output_count - desc.window - temp_count) / desc.step + (temp_count == 0 ? 1 : 2));
                          }
                    }
                  if(neuron_p.Init(outputs, n, desc.window, desc.step, output_count, desc.optimization))
                     neuron = neuron_p;
                  break;
               case defNeuronLSTM:
                  neuron_p = new CNeuronLSTM();
                  if(CheckPointer(neuron_p) == POINTER_INVALID)
                    {
                     delete temp;
                     delete layers;
                     return;
                    }
                  output_count = (next != NULL ? next.window : desc.step);
                  if(neuron_p.Init(outputs, n, desc.window, 1, output_count, desc.optimization))
                     neuron = neuron_p;
                  break;
              }
            if(!temp.Add(neuron))
              {
               delete temp;
               delete layers;
               return;
              }
            neuron = NULL;
           }
      if(!layers.Add(temp))
        {
         delete temp;
         delete layers;
         return;
        }
     }
//---
   if(CheckPointer(opencl) == POINTER_INVALID)
      return;
//--- create kernels
   opencl.SetKernelsCount(36);
   opencl.KernelCreate(def_k_FeedForward, "FeedForward");
   opencl.KernelCreate(def_k_CalcOutputGradient, "CalcOutputGradient");
   opencl.KernelCreate(def_k_CalcHiddenGradient, "CalcHiddenGradient");
   opencl.KernelCreate(def_k_UpdateWeightsMomentum, "UpdateWeightsMomentum");
   opencl.KernelCreate(def_k_UpdateWeightsAdam, "UpdateWeightsAdam");
   opencl.KernelCreate(def_k_UpdateWeightsLS, "UpdateWeightsLS");
   opencl.KernelCreate(def_k_AttentionGradients, "AttentionInsideGradients");
   opencl.KernelCreate(def_k_AttentionOut, "AttentionOut");
   opencl.KernelCreate(def_k_AttentionScore, "AttentionScore");
   opencl.KernelCreate(def_k_CalcHiddenGradientConv, "CalcHiddenGradientConv");
   opencl.KernelCreate(def_k_CalcInputGradientProof, "CalcInputGradientProof");
   opencl.KernelCreate(def_k_FeedForwardConv, "FeedForwardConv");
   opencl.KernelCreate(def_k_FeedForwardProof, "FeedForwardProof");
   opencl.KernelCreate(def_k_MatrixSum, "SumMatrix");
   opencl.KernelCreate(def_k_Matrix5Sum, "Sum5Matrix");
   opencl.KernelCreate(def_k_UpdateWeightsConvAdam, "UpdateWeightsConvAdam");
   opencl.KernelCreate(def_k_UpdateWeightsConvLS, "UpdateWeightsConvLS");
   opencl.KernelCreate(def_k_UpdateWeightsConvMomentum, "UpdateWeightsConvMomentum");
   opencl.KernelCreate(def_k_Normilize, "Normalize");
   opencl.KernelCreate(def_k_NormilizeWeights, "NormalizeWeights");
   opencl.KernelCreate(def_k_ConcatenateMatrix, "ConcatenateBuffers");
   opencl.KernelCreate(def_k_DeconcatenateMatrix, "DeconcatenateBuffers");
   opencl.KernelCreate(def_k_MHAttentionGradients, "MHAttentionInsideGradients");
   opencl.KernelCreate(def_k_MHAttentionScore, "MHAttentionScore");
   opencl.KernelCreate(def_k_MHAttentionOut, "MHAttentionOut");
   opencl.KernelCreate(def_k_BatchFeedForward, "BatchFeedForward");
   opencl.KernelCreate(def_k_CalcHiddenGradientBatch, "CalcHiddenGradientBatch");
   opencl.KernelCreate(def_k_UpdateBatchOptionsMomentum, "UpdateBatchOptionsMomentum");
   opencl.KernelCreate(def_k_UpdateBatchOptionsAdam, "UpdateBatchOptionsAdam");
   opencl.KernelCreate(def_k_VAEFeedForward, "VAE_FeedForward");
   opencl.KernelCreate(def_k_VAECalcHiddenGradient, "VAE_CalcHiddenGradient");
   opencl.KernelCreate(def_k_LSTM_UpdateWeightsAdam, "LSTM_UpdateWeightsAdam");
   opencl.KernelCreate(def_k_LSTM_HiddenGradient, "LSTM_HiddenGradient");
   opencl.KernelCreate(def_k_LSTM_FeedForward, "LSTM_FeedForward");
   opencl.KernelCreate(def_k_LSTM_ConcatenatedGradient, "LSTM_ConcatenatedGradient");
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::feedForward(CArrayFloat *inputVals, int window = 1, bool tem = true)
  {
   if(CheckPointer(layers) == POINTER_INVALID || CheckPointer(inputVals) == POINTER_INVALID || layers.Total() <= 1)
      return false;
//---
   CLayer *previous = NULL;
   CLayer *current = layers.At(0);
   int total = MathMin(current.Total(), inputVals.Total());
   CNeuronBase *neuron = NULL;
   if(CheckPointer(opencl) == POINTER_INVALID)
     {
      for(int i = 0; i < total; i++)
        {
         neuron = current.At(i);
         if(CheckPointer(neuron) == POINTER_INVALID)
            return false;
         int pos = i;
         int d = 0;
         if(window > 1)
           {
            d = i % window;
            pos = (i - d) / window;
           }
         neuron.setOutputVal(inputVals.At(i) + (float)(tem ? (d % 2 == 0 ? sin(pos / pow(10000, (2 * d + 1) / (window + 1))) : cos(pos / pow(10000, (2 * d + 1) / (window + 1)))) : 0));
        }
     }
   else
     {
      CNeuronBaseOCL *neuron_ocl = current.At(0);
      CBufferFloat *inputs = neuron_ocl.getOutput();
      int total_data = inputVals.Total();
      if(!inputs.Resize(total_data))
         return false;
      for(int d = 0; d < total_data; d++)
        {
         int pos = d;
         int dim = 0;
         if(window > 1)
           {
            dim = d % window;
            pos = (d - dim) / window;
           }
         float value = pos / pow(10000, (2 * dim + 1) / (float)(window + 1));
         value = (float)(tem ? (dim % 2 == 0 ? sin(value) : cos(value)) : 0);
         value += inputVals.At(d);
         if(!inputs.Update(d, value))
            return false;
        }
      if(!inputs.BufferWrite())
         return false;
     }
//---
   CObject *temp = NULL;
   for(int l = 1; l < layers.Total(); l++)
     {
      previous = current;
      current = layers.At(l);
      if(CheckPointer(current) == POINTER_INVALID)
         return false;
      //---
      if(CheckPointer(opencl) != POINTER_INVALID)
        {
         CNeuronBaseOCL *current_ocl = current.At(0);
         if(!current_ocl.FeedForward(previous.At(0)))
            return false;
         continue;
        }
      //---
      total = current.Total();
      if(current.At(0).Type() == defNeuron)
         total--;
      //---
      for(int n = 0; n < total; n++)
        {
         neuron = current.At(n);
         if(CheckPointer(neuron) == POINTER_INVALID)
            return false;
         if(previous.At(0).Type() == defNeuron)
           {
            temp = previous;
            if(!neuron.feedForward(temp))
               return false;
            continue;
           }
         if(neuron.Type() == defNeuron)
           {
            if(n == 0)
              {
               CLayer *temp_l = new CLayer(total);
               if(CheckPointer(temp_l) == POINTER_INVALID)
                  return false;
               CNeuronProof *proof = NULL;
               for(int p = 0; p < previous.Total(); p++)
                 {
                  proof = previous.At(p);
                  if(CheckPointer(proof) == POINTER_INVALID)
                     return false;
                  temp_l.AddArray(proof.getOutputLayer());
                 }
               temp = temp_l;
              }
            if(!neuron.feedForward(temp))
               return false;
            if(n == total - 1)
              {
               CLayer *temp_l = temp;
               temp_l.FreeMode(false);
               temp_l.Shutdown();
               delete temp_l;
              }
            continue;
           }
         temp = previous.At(n);
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!neuron.feedForward(temp))
            return false;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::backProp(CArrayFloat *targetVals)
  {
   if(CheckPointer(targetVals) == POINTER_INVALID || CheckPointer(layers) == POINTER_INVALID)
      return false;
   if(CheckPointer(opencl) != POINTER_INVALID)
     {
      if(!backPropOCL(targetVals, false))
         return false;
      return true;
     }
//---
   CLayer *outputLayer = layers.At(layers.Total() - 1);
   if(CheckPointer(outputLayer) == POINTER_INVALID)
      return false;
//---
   float error = 0.0;
   int total = outputLayer.Total() - 1;
   for(int n = 0; n < total && !IsStopped(); n++)
     {
      CNeuron *neuron = outputLayer.At(n);
      float target = targetVals.At(n);
      float delta = (target > 1 ? 1 : target < -1 ? -1 : target) - neuron.getOutputVal();
      error += delta * delta;
      neuron.calcOutputGradients(targetVals.At(n));
     }
   error /= (float)total;
   error = (float)sqrt(error);
   backPropCount++;
   recentAverageError += (error - recentAverageError) / fmin(recentAverageSmoothingFactor, backPropCount);
//---
   CNeuronBase *neuron = NULL;
   CObject *temp = NULL;
   for(int layerNum = layers.Total() - 2; layerNum > 0; layerNum--)
     {
      CLayer *hiddenLayer = layers.At(layerNum);
      CLayer *nextLayer = layers.At(layerNum + 1);
      total = hiddenLayer.Total();
      for(int n = 0; n < total && !IsStopped(); ++n)
        {
         neuron = hiddenLayer.At(n);
         if(nextLayer.At(0).Type() == defNeuron)
           {
            temp = nextLayer;
            neuron.calcHiddenGradients(temp);
            continue;
           }
         if(neuron.Type() == defNeuron)
           {
            float g = 0;
            for(int i = 0; i < nextLayer.Total(); i++)
              {
               temp = nextLayer.At(i);
               neuron.calcHiddenGradients(temp);
               g += neuron.getGradient();
              }
            neuron.setGradient(g);
            continue;
           }
         temp = nextLayer.At(n);
         neuron.calcHiddenGradients(temp);
        }
     }
//---
   for(int layerNum = layers.Total() - 1; layerNum > 0; layerNum--)
     {
      CLayer *layer = layers.At(layerNum);
      CLayer *prevLayer = layers.At(layerNum - 1);
      total = layer.Total() - (layer.At(0).Type() == defNeuron ? 1 : 0);
      int n_conv = 0;
      for(int n = 0; n < total && !IsStopped(); n++)
        {
         neuron = layer.At(n);
         if(CheckPointer(neuron) == POINTER_INVALID)
            return false;
         if(neuron.Type() == defNeuronProof)
            continue;
         switch(prevLayer.At(0).Type())
           {
            case defNeuron:
               temp = prevLayer;
               neuron.updateInputWeights(temp);
               break;
            case defNeuronConv:
            case defNeuronProof:
            case defNeuronLSTM:
               if(neuron.Type() == defNeuron)
                 {
                  for(n_conv = 0; n_conv < prevLayer.Total(); n_conv++)
                    {
                     temp = prevLayer.At(n_conv);
                     neuron.updateInputWeights(temp);
                    }
                 }
               else
                 {
                  temp = prevLayer.At(n);
                  neuron.updateInputWeights(temp);
                 }
               break;
            default:
               temp = NULL;
               break;
           }
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::backPropOCL(CArrayFloat *targetVals, bool layer_by_layer = true)
  {
   if(CheckPointer(targetVals) == POINTER_INVALID || CheckPointer(layers) == POINTER_INVALID || CheckPointer(opencl) == POINTER_INVALID)
      return false;
   CLayer *currentLayer = layers.At(layers.Total() - 1);
   if(CheckPointer(currentLayer) == POINTER_INVALID)
      return false;
//---
   float error = 0.0;
   int total = targetVals.Total();
   float result[];
   CNeuronBaseOCL *neuron = currentLayer.At(0);
   if(neuron.getOutputVal(result) < total)
      return false;
   for(int n = 0; n < total && !IsStopped(); n++)
     {
      float target = targetVals.At(n);
      float delta = (target > 1 ? 1 : target < -1 ? -1 : target) - result[n];
      error += (float)MathPow(delta, 2);
     }
   error = (float)sqrt(error / total);
//---
   if(!neuron.calcOutputGradients(targetVals, error))
      return false;
//---
   backPropCount++;
   recentAverageError += (error - recentAverageError) / fmin(recentAverageSmoothingFactor, backPropCount);
//---
   if(layer_by_layer)
     {
      total = layers.Total();
      for(int layer_update = 1; layer_update < total; layer_update++)
        {
         for(int layerNum = total - 2; layerNum > layer_update - 1; layerNum--)
           {
            CLayer *nextLayer = currentLayer;
            currentLayer = layers.At(layerNum);
            neuron = currentLayer.At(0);
            if(!neuron.calcHiddenGradients(nextLayer.At(0)))
               return false;
           }
         //---
         CLayer *prevLayer = layers.At(layer_update - 1);
         currentLayer = layers.At(layer_update);
         neuron = currentLayer.At(0);
         if(!neuron.UpdateInputWeights(prevLayer.At(0)))
            return false;
         //---
         for(int layerNum = layer_update; layerNum < total; layerNum++)
           {
            currentLayer = layers.At(layerNum);
            if(CheckPointer(currentLayer) == POINTER_INVALID)
               return false;
            //---
            CNeuronBaseOCL *current_ocl = currentLayer.At(0);
            if(!current_ocl.FeedForward(prevLayer.At(0)))
               return false;
            prevLayer = currentLayer;
           }
        }
      return true;
     }
//--- Calc Hidden Gradients
//CObject *temp=NULL;
   total = layers.Total();
   for(int layerNum = total - 2; layerNum > 0; layerNum--)
     {
      CLayer *nextLayer = currentLayer;
      currentLayer = layers.At(layerNum);
      neuron = currentLayer.At(0);
      if(!neuron.calcHiddenGradients(nextLayer.At(0)))
         return false;
     }
//---
   CLayer *prevLayer = layers.At(total - 1);
   for(int layerNum = total - 1; layerNum > 0; layerNum--)
     {
      currentLayer = prevLayer;
      prevLayer = layers.At(layerNum - 1);
      neuron = currentLayer.At(0);
      if(!neuron.UpdateInputWeights(prevLayer.At(0)))
         return false;
     }
//---
   for(int layerNum = 0; layerNum < total; layerNum++)
     {
      currentLayer = layers.At(layerNum);
      CNeuronBaseOCL *temp = currentLayer.At(0);
      if(!temp.TrainMode())
         continue;
      if(!temp.getGradient().BufferRead())
         return false;
      break;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNet::getResults(CBufferFloat *&resultVals)
  {
   if(CheckPointer(resultVals) == POINTER_INVALID)
     {
      resultVals = new CBufferFloat();
      if(CheckPointer(resultVals) == POINTER_INVALID)
         return;
     }
//---
   resultVals.Clear();
   if(CheckPointer(layers) == POINTER_INVALID || layers.Total() <= 0)
      return;
//---
   CLayer *output = layers.At(layers.Total() - 1);
   if(CheckPointer(output) == POINTER_INVALID)
      return;
//---
   if(CheckPointer(opencl) != POINTER_INVALID && output.At(0).Type() >= defNeuronBaseOCL)
     {
      CNeuronBaseOCL *temp = output.At(0);
      temp.getOutputVal(resultVals);
      return;
     }
   CNeuronBase *neuron = NULL;
   CLayer *temp = NULL;
   int total = output.Total();
   if(output.At(0).Type() == defNeuron)
      total--;
//---
   for(int i = 0; i < total; i++)
     {
      neuron = output.At(i);
      if(CheckPointer(neuron) == POINTER_INVALID)
         continue;
      if(neuron.Type() == defNeuron)
        {
         resultVals.Add(neuron.getOutputVal());
         continue;
        }
      CNeuronProof *n = neuron;
      temp = n.getOutputLayer();
      for(int ii = 0; ii < temp.Total(); ii++)
        {
         neuron = temp.At(ii);
         if(CheckPointer(neuron) == POINTER_INVALID)
            continue;
         resultVals.Add(neuron.getOutputVal());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::Save(string file_name, float error, float undefine, float forecast, datetime time, bool common = true)
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_FORWARD) || MQLInfoInteger(MQL_OPTIMIZATION))
      return true;
   if(file_name == NULL)
      return false;
//---
   int handle = FileOpen(file_name, (common ? FILE_COMMON : 0) | FILE_BIN | FILE_WRITE);
   if(handle == INVALID_HANDLE)
      return false;
//---
   if(FileWriteDouble(handle, error) <= 0 || FileWriteDouble(handle, undefine) <= 0 || FileWriteDouble(handle, forecast) <= 0 || FileWriteLong(handle, (long)time) <= 0)
     {
      FileClose(handle);
      return false;
     }
   bool result = layers.Save(handle);
   FileFlush(handle);
   FileClose(handle);
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::Load(string file_name, float &error, float &undefine, float &forecast, datetime &time, bool common = true)
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_FORWARD) || MQLInfoInteger(MQL_OPTIMIZATION))
      return false;
//---
   if(file_name == NULL)
      return false;
//---
   Print(file_name);
   int handle = FileOpen(file_name, (common ? FILE_COMMON : 0) | FILE_BIN | FILE_READ);
   if(handle == INVALID_HANDLE)
      return false;
//---
   error = (float)FileReadDouble(handle);
   undefine = (float)FileReadDouble(handle);
   forecast = (float)FileReadDouble(handle);
   time = (datetime)FileReadLong(handle);
   recentAverageError = fmax(error, 0);
//---
   if(CheckPointer(layers) != POINTER_INVALID)
      layers.Clear();
   else
      layers = new CArrayLayer();
   int i = 0, num;
//---
   if(CheckPointer(opencl) == POINTER_INVALID)
     {
      opencl = new COpenCLMy();
      if(CheckPointer(opencl) != POINTER_INVALID && !opencl.Initialize(cl_program, true))
         delete opencl;
      else
        {
         //--- create kernels
         opencl.SetKernelsCount(36);
         opencl.KernelCreate(def_k_FeedForward, "FeedForward");
         opencl.KernelCreate(def_k_CalcOutputGradient, "CalcOutputGradient");
         opencl.KernelCreate(def_k_CalcHiddenGradient, "CalcHiddenGradient");
         opencl.KernelCreate(def_k_UpdateWeightsMomentum, "UpdateWeightsMomentum");
         opencl.KernelCreate(def_k_UpdateWeightsAdam, "UpdateWeightsAdam");
         opencl.KernelCreate(def_k_UpdateWeightsLS, "UpdateWeightsLS");
         opencl.KernelCreate(def_k_AttentionGradients, "AttentionInsideGradients");
         opencl.KernelCreate(def_k_AttentionOut, "AttentionOut");
         opencl.KernelCreate(def_k_AttentionScore, "AttentionScore");
         opencl.KernelCreate(def_k_CalcHiddenGradientConv, "CalcHiddenGradientConv");
         opencl.KernelCreate(def_k_CalcInputGradientProof, "CalcInputGradientProof");
         opencl.KernelCreate(def_k_FeedForwardConv, "FeedForwardConv");
         opencl.KernelCreate(def_k_FeedForwardProof, "FeedForwardProof");
         opencl.KernelCreate(def_k_MatrixSum, "SumMatrix");
         opencl.KernelCreate(def_k_Matrix5Sum, "Sum5Matrix");
         opencl.KernelCreate(def_k_UpdateWeightsConvAdam, "UpdateWeightsConvAdam");
         opencl.KernelCreate(def_k_UpdateWeightsConvMomentum, "UpdateWeightsConvMomentum");
         opencl.KernelCreate(def_k_UpdateWeightsConvLS, "UpdateWeightsConvLS");
         opencl.KernelCreate(def_k_Normilize, "Normalize");
         opencl.KernelCreate(def_k_NormilizeWeights, "NormalizeWeights");
         opencl.KernelCreate(def_k_ConcatenateMatrix, "ConcatenateBuffers");
         opencl.KernelCreate(def_k_DeconcatenateMatrix, "DeconcatenateBuffers");
         opencl.KernelCreate(def_k_MHAttentionGradients, "MHAttentionInsideGradients");
         opencl.KernelCreate(def_k_MHAttentionScore, "MHAttentionScore");
         opencl.KernelCreate(def_k_MHAttentionOut, "MHAttentionOut");
         opencl.KernelCreate(def_k_Dropout, "Dropout");
         opencl.KernelCreate(def_k_BatchFeedForward, "BatchFeedForward");
         opencl.KernelCreate(def_k_CalcHiddenGradientBatch, "CalcHiddenGradientBatch");
         opencl.KernelCreate(def_k_UpdateBatchOptionsMomentum, "UpdateBatchOptionsMomentum");
         opencl.KernelCreate(def_k_UpdateBatchOptionsAdam, "UpdateBatchOptionsAdam");
         opencl.KernelCreate(def_k_VAEFeedForward, "VAE_FeedForward");
         opencl.KernelCreate(def_k_VAECalcHiddenGradient, "VAE_CalcHiddenGradient");
         opencl.KernelCreate(def_k_LSTM_ConcatenatedGradient, "LSTM_ConcatenatedGradient");
         opencl.KernelCreate(def_k_LSTM_HiddenGradient, "LSTM_HiddenGradient");
         opencl.KernelCreate(def_k_LSTM_FeedForward, "LSTM_FeedForward");
         opencl.KernelCreate(def_k_LSTM_UpdateWeightsAdam, "LSTM_UpdateWeightsAdam");
        }
     }
//--- check
//--- read and check start marker - 0xFFFFFFFFFFFFFFFF
   long temp = FileReadLong(handle);
   if(temp == -1)
     {
      //--- read and check array type
      if(FileReadInteger(handle, INT_VALUE) != layers.Type())
        {
         FileClose(handle);
         return(false);
        }
     }
   else
     {
      FileClose(handle);
      return(false);
     }
//--- read array length
   num = FileReadInteger(handle, INT_VALUE);
//--- read array
   if(num != 0)
     {
      for(i = 0; i < num; i++)
        {
         //--- create new element
         CLayer *Layer = new CLayer(0, handle, opencl);
         if(!Layer.Load(handle))
            break;
         if(!layers.Add(Layer))
            break;
        }
     }
   FileClose(handle);
//--- result
   return (layers.Total() == num);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::TrainMode(bool flag)
  {
   if(CheckPointer(layers) == POINTER_INVALID || layers.Total() <= 1)
      return false;
//---
   CLayer *current = NULL;
//---
   CObject *temp = NULL;
   for(int l = 0; l < layers.Total(); l++)
     {
      current = layers.At(l);
      if(CheckPointer(current) == POINTER_INVALID || CheckPointer(current.At(0)) == POINTER_INVALID)
         return false;
      //---
      if(CheckPointer(opencl) != POINTER_INVALID)
        {
         CNeuronBaseOCL *current_ocl = current.At(0);
         current_ocl.TrainMode(flag);
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::Save(const int file_handle)
  {
   if(!CNeuronBase::Save(file_handle) || !OutputLayer.Save(file_handle))
      return false;
   if(FileWriteInteger(file_handle, iWindow, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, iStep, INT_VALUE) < INT_VALUE)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProof::Load(const int file_handle)
  {
   if(!CNeuronBase::Load(file_handle) || !OutputLayer.Load(file_handle))
      return false;
   iWindow = FileReadInteger(file_handle, INT_VALUE);
   iStep = FileReadInteger(file_handle, INT_VALUE);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::Save(const int file_handle)
  {
   if(!CNeuronProof::Save(file_handle))
      return false;
   if(FileWriteDouble(file_handle, param) < 8)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::Load(const int file_handle)
  {
   if(!CNeuronProof::Load(file_handle))
      return false;
   param = (float)FileReadDouble(file_handle);
//---
   return true;
  }
//+------------------------------------------------------------------+
///\class CNeuronLSTM
/// Class of recurrent LSTM unit
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8385#para5">the link.</A>
//+------------------------------------------------------------------+
class CNeuronLSTM    :  public CNeuronProof
  {
protected:
   CLayer            *ForgetGate;                                    ///< Object of forget gate
   CLayer            *InputGate;                                     ///< Object of input gate
   CLayer            *OutputGate;                                    ///< Object of output gate
   CLayer            *NewContent;                                    ///< Object of new content
   CArrayFloat       *Memory;                                        ///< Memory array
   CArrayFloat       *PrevMemory;                                    ///< Ravious iteration memory array
   CArrayFloat       *Input;                                         ///< Input data
   CArrayFloat       *InputGradient;                                 ///< Gradient on previous layer
   //---
   virtual bool      feedForward(CLayer *prevLayer);                    ///< Feed Forward method. Detailed description on <A HREF="https://www.mql5.com/ru/articles/8385#para52">the link.</A>@param prevLayer Pointer to previos layer.
   virtual bool      calcHiddenGradients(CLayer *&nextLayer);           ///< Method to transfer gradient to previous layer. @param nextLayer Pointer to next layer.
   virtual bool      updateInputWeights(CLayer *&prevLayer);            ///< Method for updating weights.@param prevLayer Pointer to previos layer.
   virtual bool      updateInputWeights(CLayer *gate, CArrayFloat *input_data); ///< Method for updating gates' weights.@param gate Pointer to gate. @param input_data Pointer to tensor with input data.
   virtual bool      InitLayer(CLayer *layer, int numUnits, int numOutputs, ENUM_OPTIMIZATION optimization_type);
   ///< Method of gate initialization @param[in] layer Pointer to gate @param[in] numUnits Number of units in gate @param[in] numOutputs Number of outputs @param[in] optimization_type Type of optimization (#ENUM_OPTIMIZATION)
   virtual CArrayFloat *CalculateGate(CLayer *gate, CArrayFloat *sequence); ///< Method of calculation gate iteration @param[in] gate Pointer to gate @param[in] sequence Input data @return Array of output data

public:
   /** Constructor */
                     CNeuronLSTM(void);
   /** Destructor */~CNeuronLSTM(void);
   virtual bool      Init(uint numOutputs, uint myIndex, int window, int step, int units_count, ENUM_OPTIMIZATION optimization_type);
   ///< Unit initialization method. Detailed description on <A HREF="https://www.mql5.com/ru/articles/8385#para51">the link.</A>
   //---
   virtual CLayer    *getOutputLayer(void)  { return OutputLayer;  }    ///< Method for getting a pointer to the resulting neural layer. Not used in fully connected neural networks.@return Pointer to layer.
   virtual bool      calcInputGradients(CLayer *prevLayer) ;
   virtual bool      calcInputGradients(CNeuronBase *prevNeuron, uint index) ;
   //--- methods for working with files
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual int       Type(void)   const   {  return defNeuronLSTM;   }///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronLSTM::CNeuronLSTM(void)
  {
   ForgetGate     =  new CLayer();
   InputGate      =  new CLayer();
   OutputGate     =  new CLayer();
   NewContent     =  new CLayer();
   Memory         =  new CArrayFloat();
   PrevMemory     =  new CArrayFloat();
   Input          =  new CArrayFloat();
   InputGradient  =  new CArrayFloat();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronLSTM::~CNeuronLSTM(void)
  {
   if(CheckPointer(ForgetGate) != POINTER_INVALID)
      delete ForgetGate;
   if(CheckPointer(InputGate) != POINTER_INVALID)
      delete InputGate;
   if(CheckPointer(OutputGate) != POINTER_INVALID)
      delete OutputGate;
   if(CheckPointer(NewContent) != POINTER_INVALID)
      delete NewContent;
   if(CheckPointer(Memory) != POINTER_INVALID)
      delete Memory;
   if(CheckPointer(PrevMemory) != POINTER_INVALID)
      delete PrevMemory;
   if(CheckPointer(Input) != POINTER_INVALID)
      delete Input;
   if(CheckPointer(InputGradient) != POINTER_INVALID)
      delete InputGradient;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::Init(uint numOutputs, uint myIndex, int window, int step, int units_count, ENUM_OPTIMIZATION optimization_type)
  {
   if(units_count <= 0)
      return false;
//--- Init Layers
   if(!CNeuronProof::Init(numOutputs, myIndex, window, step, units_count, optimization_type))
      return false;
   if(!InitLayer(ForgetGate, units_count, window + units_count, optimization_type))
      return false;
   if(!InitLayer(InputGate, units_count, window + units_count, optimization_type))
      return false;
   if(!InitLayer(OutputGate, units_count, window + units_count, optimization_type))
      return false;
   if(!InitLayer(NewContent, units_count, window + units_count, optimization_type))
      return false;
   if(!Memory.Reserve(units_count))
      return false;
   if(!PrevMemory.Reserve(units_count))
      return false;
   CNeuron *temp;
   for(int i = 0; i < units_count; i++)
     {
      if(!Memory.Add(0))
         return false;
      if(!PrevMemory.Add(0))
         return false;
      temp = OutputLayer.At(i);
      temp.setOutputVal(0);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::InitLayer(CLayer *layer, int numUnits, int numOutputs, ENUM_OPTIMIZATION optimization_type)
  {
   if(CheckPointer(layer) == POINTER_INVALID)
     {
      layer = new CLayer(numOutputs);
      if(CheckPointer(layer) == POINTER_INVALID)
         return false;
     }
   else
      layer.Clear();
   if(!layer.Reserve(numUnits))
      return false;
//---
   CNeuron *temp;
   for(int i = 0; i < numUnits; i++)
     {
      temp = new CNeuron();
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      if(!temp.Init(numOutputs + 1, i, optimization_type))
         return false;
      if(!layer.Add(temp))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::feedForward(CLayer *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID || prevLayer.Total() <= 0)
      return false;
   CNeuronBase *temp;
   CConnection *temp_con;
   if(CheckPointer(Input) == POINTER_INVALID)
     {
      Input = new CArrayFloat();
      if(CheckPointer(Input) == POINTER_INVALID)
         return false;
     }
   else
      Input.Clear();
//--- Concatenate input sequence
   int total = prevLayer.Total();
   if(!Input.Reserve(total + OutputLayer.Total()))
      return false;
   for(int i = 0; i < total; i++)
     {
      temp = prevLayer.At(i);
      if(CheckPointer(temp) == POINTER_INVALID || !Input.Add(temp.getOutputVal()))
         return false;
     }
   total = OutputLayer.Total();
   for(int i = 0; i < total; i++)
     {
      temp = OutputLayer.At(i);
      if(CheckPointer(temp) == POINTER_INVALID || !Input.Add(temp.getOutputVal()))
         return false;
     }
   int total_data = Input.Total();
//--- Calculated forget gate
   CArrayFloat *forget_gate = CalculateGate(ForgetGate, Input);
   if(CheckPointer(forget_gate) == POINTER_INVALID)
      return false;
//--- Calculated input gate
   CArrayFloat *input_gate = CalculateGate(InputGate, Input);
   if(CheckPointer(input_gate) == POINTER_INVALID)
      return false;
//--- Calculated output gate
   CArrayFloat *output_gate = CalculateGate(OutputGate, Input);
   if(CheckPointer(output_gate) == POINTER_INVALID)
      return false;
//--- Calculated new content
   CArrayFloat *new_content = new CArrayFloat();
   if(CheckPointer(new_content) == POINTER_INVALID)
      return false;
   total = NewContent.Total();
   for(int i = 0; i < total; i++)
     {
      temp = NewContent.At(i);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      float val = 0;
      for(int c = 0; c < total_data; c++)
        {
         temp_con = temp.Connections.At(c);
         if(CheckPointer(temp_con) == POINTER_INVALID)
            return false;
         val += temp_con.weight * Input.At(c);
        }
      val = TanhFunction(val);
      temp.setOutputVal(val);
      if(!new_content.Add(val))
         return false;
     }
//--- Calculated output sequences
   for(int i = 0; i < total; i++)
     {
      if(PrevMemory.Total() <= i)
         PrevMemory.Add(Memory.At(i));
      else
         PrevMemory.Update(i, Memory.At(i));
      float value = Memory.At(i) * forget_gate.At(i) + new_content.At(i) * input_gate.At(i);
      if(!Memory.Update(i, value))
         return false;
      temp = OutputLayer.At(i);
      value = TanhFunction(value) * output_gate.At(i);
      temp.setOutputVal(value);
     }
//---
   delete forget_gate;
   delete input_gate;
   delete new_content;
   delete output_gate;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CArrayFloat *CNeuronLSTM::CalculateGate(CLayer *gate, CArrayFloat *sequence)
  {
   CNeuronBase *temp;
   CConnection *temp_con;
   CArrayFloat *result = new CArrayFloat();
   if(CheckPointer(gate) == POINTER_INVALID)
      return NULL;
   int total = gate.Total();
   int total_data = sequence.Total();
   for(int i = 0; i < total; i++)
     {
      temp = gate.At(i);
      if(CheckPointer(temp) == POINTER_INVALID)
        {
         delete result;
         return NULL;
        }
      float val = 0;
      for(int c = 0; c < total_data; c++)
        {
         temp_con = temp.Connections.At(c);
         if(CheckPointer(temp_con) == POINTER_INVALID)
           {
            delete result;
            return NULL;
           }
         val += temp_con.weight * (sequence.At(c) == DBL_MAX ? 1 : sequence.At(c));
        }
      val = SigmoidFunction(val);
      temp.setOutputVal(val);
      if(!result.Add(val))
        {
         delete result;
         return NULL;
        }
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::calcHiddenGradients(CLayer *&nextLayer)
  {
   if(CheckPointer(InputGradient) == POINTER_INVALID)
     {
      InputGradient = new CArrayFloat();
      if(CheckPointer(InputGradient) == POINTER_INVALID)
         return false;
     }
   else
      InputGradient.Clear();
//---
   int total = OutputLayer.Total();
   CNeuron *temp;
   CArrayFloat *MemoryGradient = new CArrayFloat();
   CNeuron *gate;
   CConnection *con;
//---
   if(nextLayer != OutputLayer)
      for(int i = 0; i < total; i++)
        {
         temp = OutputLayer.At(i);
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         temp.setGradient(temp.sumDOW(nextLayer));
        }
//--- Calculated memory  and output gate gradients
   if(CheckPointer(MemoryGradient) == POINTER_INVALID)
      return false;
   if(!MemoryGradient.Reserve(total))
      return false;
   for(int i = 0; i < total; i++)
     {
      temp = OutputLayer.At(i);
      gate = OutputGate.At(i);
      if(CheckPointer(gate) == POINTER_INVALID)
         return false;
      float value = temp.getGradient() * gate.getOutputVal();
      value = TanhFunctionDerivative(Memory.At(i)) * value;
      if(i >= MemoryGradient.Total())
        {
         if(!MemoryGradient.Add(value))
            return false;
        }
      else
        {
         value = MemoryGradient.At(i) + value;
         if(!MemoryGradient.Update(i, value))
            return false;
        }
      gate.setGradient(gate.getOutputVal() != 0 && temp.getGradient() != 0 ? temp.getGradient()*temp.getOutputVal()*SigmoidFunctionDerivative(gate.getOutputVal()) / gate.getOutputVal() : 0);
      //--- Calcculated gates and new content gradients
      gate = ForgetGate.At(i);
      if(CheckPointer(gate) == POINTER_INVALID)
         return false;
      gate.setGradient(gate.getOutputVal() != 0 && value != 0 ? value * SigmoidFunctionDerivative(gate.getOutputVal()) : 0);
      gate = InputGate.At(i);
      temp = NewContent.At(i);
      if(CheckPointer(gate) == POINTER_INVALID)
         return false;
      gate.setGradient(gate.getOutputVal() != 0 && value != 0 ? value * temp.getOutputVal()*SigmoidFunctionDerivative(gate.getOutputVal()) : 0);
      temp.setGradient(temp.getOutputVal() != 0 && value != 0 ? value * gate.getOutputVal()*TanhFunctionDerivative(temp.getOutputVal()) : 0);
     }
//--- Calculated input gradients
   int total_inp = temp.getConnections().Total();
   for(int n = 0; n < total_inp; n++)
     {
      float value = 0;
      for(int i = 0; i < total; i++)
        {
         temp = ForgetGate.At(i);
         con = temp.getConnections().At(n);
         value += temp.getGradient() * con.weight;
         //---
         temp = InputGate.At(i);
         con = temp.getConnections().At(n);
         value += temp.getGradient() * con.weight;
         //---
         temp = OutputGate.At(i);
         con = temp.getConnections().At(n);
         value += temp.getGradient() * con.weight;
         //---
         temp = NewContent.At(i);
         con = temp.getConnections().At(n);
         value += temp.getGradient() * con.weight;
        }
      if(InputGradient.Total() >= n)
        {
         if(!InputGradient.Add(value))
            return false;
        }
      else
         if(!InputGradient.Update(n, value))
            return false;
     }
//--- Calculated gradients for prev. state
   int shift = total_inp - total;
   for(int i = 0; i < total; i++)
     {
      temp = OutputLayer.At(i);
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      temp.setGradient(InputGradient.At(shift + i));
     }
//--- Calculated memory  and output gate gradients
   for(int i = 0; i < total; i++)
     {
      temp = OutputLayer.At(i);
      gate = OutputGate.At(i);
      if(CheckPointer(gate) == POINTER_INVALID)
         return false;
      float value = temp.getGradient() * gate.getPrevVal();
      value = MemoryGradient.At(i) + TanhFunctionDerivative(PrevMemory.At(i)) * value;
      if(!MemoryGradient.Update(i, value))
         return false;
      gate.setGradient(gate.getGradient() + (gate.getPrevVal() != 0 && temp.getGradient() != 0 ? temp.getGradient()*temp.getPrevVal()*SigmoidFunctionDerivative(gate.getPrevVal()) / gate.getPrevVal() : 0));
      //--- Calcculated gates and new content gradients
      gate = ForgetGate.At(i);
      if(CheckPointer(gate) == POINTER_INVALID)
         return false;
      gate.setGradient(gate.getGradient() + (gate.getPrevVal() != 0 && value != 0 ? value * SigmoidFunctionDerivative(gate.getPrevVal()) : 0));
      gate = InputGate.At(i);
      temp = NewContent.At(i);
      if(CheckPointer(gate) == POINTER_INVALID)
         return false;
      gate.setGradient(gate.getGradient() + (gate.getPrevVal() != 0 && value != 0 ? value * temp.getPrevVal()*SigmoidFunctionDerivative(gate.getPrevVal()) : 0));
      temp.setGradient(temp.getGradient() + (temp.getPrevVal() != 0 && value != 0 ? value * gate.getPrevVal()*TanhFunctionDerivative(temp.getPrevVal()) : 0));
     }
//---
   delete MemoryGradient;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::updateInputWeights(CLayer *&prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID || CheckPointer(Input) == POINTER_INVALID)
      return false;
//---
   if(!updateInputWeights(ForgetGate, Input) || !updateInputWeights(InputGate, Input) || !updateInputWeights(OutputGate, Input)
      || !updateInputWeights(NewContent, Input))
     {
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::updateInputWeights(CLayer *gate, CArrayFloat *input_data)
  {
   if(CheckPointer(gate) == POINTER_INVALID || CheckPointer(input_data) == POINTER_INVALID)
      return false;
   CNeuronBase *neuron;
   CConnection *con;
   int total_n = gate.Total();
   int total_data = input_data.Total();
   float lt = (float)(eta * sqrt(1 - pow(b2, t)) / (1 - pow(b1, t)));
   for(int n = 0; n < total_n; n++)
     {
      neuron = gate.At(n);
      if(CheckPointer(neuron) == POINTER_INVALID)
         return false;
      for(int i = 0; i < total_data; i++)
        {
         con = neuron.getConnections().At(i);
         if(CheckPointer(con) == POINTER_INVALID)
            return false;
         float data = input_data.At(i);
         float g = neuron.getGradient();
         if(optimization == SGD)
            con.weight += con.deltaWeight = (g != 0 && data != 0 ? eta * g * (data != DBL_MAX ? data : 1) : 0) + alpha * con.deltaWeight;
         else
           {
            con.mt = b1 * con.mt + (1 - b1) * g;
            con.vt = (float)(b2 * con.vt + (1 - b2) * pow(g, 2) + 0.00000001);
            con.weight += con.deltaWeight = (float)(lt * con.mt / sqrt(con.vt));
            t++;
           }
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::calcInputGradients(CNeuronBase *prevNeuron, uint index)
  {
   if(CheckPointer(prevNeuron) == POINTER_INVALID || CheckPointer(InputGradient) == POINTER_INVALID || InputGradient.Total() <= (int)index)
      return false;
//---
   prevNeuron.setGradient(InputGradient.At(index));
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::calcInputGradients(CLayer *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
   int total = prevLayer.Total();
   if(total <= 0)
      return false;
   CNeuronBase *neuron;
   bool result = true;
   for(int i = 0; (i < total && result); i++)
     {
      neuron = prevLayer.At(i);
      if(CheckPointer(neuron) == POINTER_INVALID)
        {
         result = false;
         break;
        }
      result = calcInputGradients(neuron, i);
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::Save(const int file_handle)
  {
   if(!CNeuronProof::Save(file_handle))
      return false;
   if(!ForgetGate.Save(file_handle))
      return false;
   if(!InputGate.Save(file_handle))
      return false;
   if(!OutputGate.Save(file_handle))
      return false;
   if(!NewContent.Save(file_handle))
      return false;
   if(!Memory.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTM::Load(const int file_handle)
  {
   if(!CNeuronProof::Load(file_handle))
      return false;
   if(!ForgetGate.Load(file_handle))
      return false;
   if(!InputGate.Load(file_handle))
      return false;
   if(!OutputGate.Load(file_handle))
      return false;
   if(!NewContent.Load(file_handle))
      return false;
   if(!Memory.Load(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNeuronBase::activationFunction(float x)
  {
   switch(activation)
     {
      case TANH:
         return TanhFunction(x);
         break;
      case SIGMOID:
         return SigmoidFunction(x);
         break;
     }
//---
   return x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNeuronBase::activationFunctionDerivative(float x)
  {
   switch(activation)
     {
      case TANH:
         return TanhFunctionDerivative(x);
         break;
      case SIGMOID:
         return SigmoidFunctionDerivative(x);
         break;
     }
//---
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
int COpenCLMy::AddBufferFromArray(T &data[], const uint data_array_offset, const uint data_array_count, const uint flags)
  {
   int result = -1;
   for(int i = 0; i < m_buffers_total; i++)
     {
      if(m_buffers[i] != INVALID_HANDLE)
         continue;
      result = i;
      break;
     }
//---
   if(result < 0)
     {
      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)
        {
         m_buffers_total = ArraySize(m_buffers);
         result = m_buffers_total - 1;
         m_buffers[result] = INVALID_HANDLE;
        }
      else
         return result;
     }
//---
   if(!BufferFromArray(result, data, data_array_offset, data_array_count, flags))
      return -1;
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COpenCLMy::AddBuffer(uint size_in_bytes, const uint flags)
  {
   int result = -1;
   for(int i = 0; i < m_buffers_total; i++)
     {
      if(m_buffers[i] != INVALID_HANDLE)
         continue;
      result = i;
      break;
     }
//---
   if(result < 0)
     {
      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)
        {
         m_buffers_total = ArraySize(m_buffers);
         result = m_buffers_total - 1;
         m_buffers[result] = INVALID_HANDLE;
        }
      else
         return result;
     }
//---
   if(!BufferCreate(result, size_in_bytes, flags))
      return -1;
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayer::CLayer(uint outputs = 0, int handle = -1, COpenCLMy *opencl = NULL)
  {
   iOutputs = outputs;
   iFileHandle = handle;
   OpenCL = opencl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLayer::Load(const int file_handle)
  {
   iFileHandle = file_handle;
   if(!CArrayObj::Load(file_handle))
      return false;
   if(CheckPointer(m_data[0]) == POINTER_INVALID)
      return false;
//---
   CNeuronBaseOCL *ocl = NULL;
   CNeuronBase    *cpu = NULL;
   switch(m_data[0].Type())
     {
      case defNeuronBaseOCL:
      case defNeuronConvOCL:
      case defNeuronAttentionOCL:
      case defNeuronMHAttentionOCL:
      case defNeuronMLMHAttentionOCL:
      case defNeuronDropoutOCL:
      case defNeuronBatchNormOCL:
      case defNeuronVAEOCL:
      case defNeuronLSTMOCL:
         ocl = m_data[0];
         iOutputs = ocl.getConnections();
         break;
      default:
         cpu = m_data[0];
         iOutputs = cpu.getConnections().Total();
         break;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNet::~CNet(void)
  {
   if(CheckPointer(layers) != POINTER_INVALID)
      delete layers;
   if(CheckPointer(opencl) != POINTER_INVALID)
     {
      opencl.Shutdown();
      delete opencl;
     }
  }
//+------------------------------------------------------------------+
///\class CBufferFloat
/// Class of OpenCL buffer data. Used for transfer data from CPU to GPU and back.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para44">the link.</A>
//+------------------------------------------------------------------+
class CBufferFloat     :  public CArrayFloat
  {
protected:
   COpenCLMy         *OpenCL;                ///< Object for working with OpenCL
   int               m_myIndex;              ///< Index of buffer
public:
   /** Constructor */
                     CBufferFloat(void);
   /** Destructor */~CBufferFloat(void);
   //---
   virtual bool      BufferInit(uint count, float value);  ///< Method for buffer initialization @param[in] count Number of items @param[in] value Initialization value
   virtual bool      BufferCreate(COpenCLMy *opencl);       ///< Method for creating new buffer @param[in] opencl Pointer to #COpenCLMy object
   virtual bool      BufferFree(void);                      ///< Method for deleting buffer from GPU
   virtual bool      BufferRead(void);                      ///< Method for reading buffer data from GPU
   virtual bool      BufferWrite(void);                     ///< Method for writing buffer data to GPU
   virtual bool      BufferSet(int index) {  if(!OpenCL.BufferFree(m_myIndex)) return false; m_myIndex = index; return true; } ///< Change buffer index number @param index New index
   virtual int       GetData(float &values[]);             ///< Read data from buffer to array @param[out] values Array to read data
   virtual int       GetData(CArrayFloat *values);         ///< Read data from buffer to array @param[out] values Array to read data
   virtual int       GetIndex(void) {  return m_myIndex; }  ///< Get buffer index @return Index
   virtual float     Maximum(void) {  return m_data[ArrayMaximum(m_data)];}
   //---
   virtual bool      AssignArray(const double &src[]);
   //---
   virtual int       Type(void)                                    const { return defBufferDouble;      }///< Identificator of class.@return Type of class
   virtual void      BufferToCSV(const string file_name);   ///< Save buffer data to CSV file @param[in] file_name File name to write data
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBufferFloat::CBufferFloat(void)  : m_myIndex(-1)
  {
   OpenCL = NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBufferFloat::~CBufferFloat(void)
  {
   if(CheckPointer(OpenCL) != POINTER_INVALID && m_myIndex >= 0)
     {
      if(OpenCL.BufferFree(m_myIndex))
        {
         m_myIndex = -1;
         OpenCL = NULL;
        }
     }
   Shutdown();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferFloat::BufferCreate(COpenCLMy *opencl)
  {
   if(CheckPointer(opencl) == POINTER_INVALID)
      return false;
//---
   if(opencl == OpenCL && m_myIndex >= 0)
      if(BufferWrite())
         return true;
//---
   if(CheckPointer(OpenCL) != POINTER_INVALID && m_myIndex >= 0)
     {
      if(OpenCL.BufferFree(m_myIndex))
        {
         m_myIndex = -1;
         OpenCL = NULL;
        }
      else
         return false;
     }
//---
   if((m_myIndex = opencl.AddBufferFromArray(m_data, 0, m_data_total, CL_MEM_READ_WRITE | CL_MEM_ALLOC_HOST_PTR)) < 0)
      return false;
   OpenCL = opencl;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferFloat::BufferFree(void)
  {
   if(CheckPointer(OpenCL) != POINTER_INVALID && m_myIndex >= 0)
      if(OpenCL.BufferFree(m_myIndex))
        {
         m_myIndex = -1;
         OpenCL = NULL;
         return true;
        }
//---
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferFloat::BufferRead(void)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || m_myIndex < 0)
      return false;
//---
   if(!OpenCL.BufferRead(m_myIndex, m_data, 0, 0, m_data_total))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferFloat::BufferWrite(void)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || m_myIndex < 0)
      return false;
//---
   return OpenCL.BufferWrite(m_myIndex, m_data, 0, 0, m_data_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferFloat::BufferInit(uint count, float value)
  {
   if(m_data_max < (int)count && !Reserve((int)count - m_data_total))
      return false;
   m_data_total = (int)fmin(ArrayInitialize(m_data, value), count);
//---
   return m_data_total == count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBufferFloat::GetData(float &values[])
  {
   if(!BufferRead())
      return false;
   return ArrayCopy(values, m_data, 0, 0, m_data_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBufferFloat::GetData(CArrayFloat *values)
  {
   if(!BufferRead())
      return -1;
   if(!values.AssignArray(GetPointer(this)))
      return -1;
   return m_data_total;
  }
//+------------------------------------------------------------------+
//| Assignment (copying) of another array                            |
//+------------------------------------------------------------------+
bool CBufferFloat::AssignArray(const double &src[])
  {
   int num = ArraySize(src);
//--- check/reserve elements of array
   Clear();
   if(m_data_max < num)
     {
      if(!Reserve(num))
         return(false);
     }
   else
      Resize(num);
//--- copy array
   for(int i = 0; i < num; i++)
     {
      m_data[i] = (float)src[i];
      m_data_total++;
     }
   m_sort_mode = -1;
//--- successful
   return(true);
  }
//+------------------------------------------------------------------+
///\ingroup neuron_base
///\class CNeuronBaseOCL
///\brief The base class of neuron for GPU calculation.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8435#para45">the link.</A>
//+------------------------------------------------------------------+
class CNeuronBaseOCL    :  public CObject
  {
protected:
   bool               bTrain;             ///< Training Mode Flag
   COpenCLMy         *OpenCL;             ///< Object for working with OpenCL
   CBufferFloat      *Output;             ///< Buffer of Output tensor
   CBufferFloat      *PrevOutput;         ///< Buffer of previous iteration Output tensor
   CBufferFloat      *Weights;            ///< Buffer of weights matrix
   CBufferFloat      *DeltaWeights;       ///< Buffer of last delta weights matrix (#SGD)
   CBufferFloat      *Gradient;           ///< Buffer of gradient tensor
   CBufferFloat      *FirstMomentum;      ///< Buffer of first momentum matrix (#ADAM)
   CBufferFloat      *SecondMomentum;     ///< Buffer of second momentum matrix (#ADAM)
   //---
   //const float      eta;
   const float       alpha;               ///< Multiplier to momentum in #SGD optimization
   uint              iBatch;              ///< Batch size used in LS optimization
   uint              t;                   ///< Count of iterations
   //---
   int               m_myIndex;           ///< Index of neuron in layer
   ENUM_ACTIVATION   activation;          ///< Activation type (#ENUM_ACTIVATION)
   ENUM_OPTIMIZATION optimization;        ///< Optimization method (#ENUM_OPTIMIZATION)
   //---
   ///\ingroup neuron_base_ff
   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL);               ///< \brief Feed Forward method of calling kernel ::FeedForward().@param NeuronOCL Pointer to previos layer.

   ///\ingroup neuron_base_opt
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL);        ///< Method for updating weights.\details Calling one of kernels ::UpdateWeightsMomentum() or ::UpdateWeightsAdam() in depends of optimization type (#ENUM_OPTIMIZATION).@param NeuronOCL Pointer to previos layer.
   virtual float     GenerateWeight(void);

public:
   /** Constructor */
                     CNeuronBaseOCL(void);
   /** Destructor */~CNeuronBaseOCL(void);
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object. #param[in] numNeurons Number of neurons in layer @param optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   virtual void      SetActivationFunction(ENUM_ACTIVATION value) {  activation = value; }      ///< Set the type of activation function (#ENUM_ACTIVATION)
   //---
   virtual int       getOutputIndex(void)          {  return Output.GetIndex();        }  ///< Get index of output buffer @return Index
   virtual int       getPrevOutIndex(void)         {  return PrevOutput.GetIndex();    }  ///< Get index of previous iteration output buffer @return Index
   virtual int       getGradientIndex(void)        {  return Gradient.GetIndex();      }  ///< Get index of gradient buffer @return Index
   virtual int       getWeightsIndex(void)         {  return Weights.GetIndex();       }  ///< Get index of weights matrix buffer @return Index
   virtual int       getDeltaWeightsIndex(void)    {  return DeltaWeights.GetIndex();  }  ///< Get index of delta weights matrix buffer (SGD)@return Index
   virtual int       getFirstMomentumIndex(void)   {  return FirstMomentum.GetIndex(); }  ///< Get index of first momentum matrix buffer (Adam)@return Index
   virtual int       getSecondMomentumIndex(void)  {  return SecondMomentum.GetIndex();}  ///< Get index of Second momentum matrix buffer (Adam)@return Index
   //---
   virtual int       getOutputVal(float &values[])   {  return Output.GetData(values);      }  ///< Get values of output buffer @param[out] values Array of data @return number of items
   virtual int       getOutputVal(CArrayFloat *values)   {  return Output.GetData(values);  }  ///< Get values of output buffer @param[out] values Array of data @return number of items
   virtual int       getPrevVal(float &values[])     {  return PrevOutput.GetData(values);  }  ///< Get values of previous iteration output buffer @param[out] values Array of data @return number of items
   virtual int       getGradient(float &values[])    {  return Gradient.GetData(values);    }  ///< Get values of gradient buffer @param[out] values Array of data @return number of items
   virtual CBufferFloat   *getOutput(void)           {  return Output;       }                 ///< Get pointer of output buffer @return Pointer to object
   virtual CBufferFloat   *getGradient(void)         {  return Gradient;     }                 ///< Get pointer of gradient buffer @return Pointer to object
   virtual int       getWeights(float &values[])     {  return Weights.GetData(values);     }  ///< Get values of weights matrix buffer @param[out] values Array of data @return number of items
   virtual int       Neurons(void)                    {  return Output.Total();              }  ///< Get number of neurons in layer @return Number of neurons
   virtual int       Activation(void)                 {  return (int)activation;             }  ///< Get type of activation function @return Type (#ENUM_ACTIVATION)
   virtual int       getConnections(void)             {  return (CheckPointer(Weights) != POINTER_INVALID ? Weights.Total() / (Gradient.Total()) : 0);   } ///< Get number of connections 1 neuron to next layer @return Number of connections
   //---
   virtual bool      FeedForward(CObject *SourceObject);                      ///< Dispatch method for defining the subroutine for feed forward process. @param SourceObject Pointer to the previous layer.
   virtual bool      calcHiddenGradients(CObject *TargetObject);              ///< Dispatch method for defining the subroutine for transferring the gradient to the previous layer. @param TargetObject Pointer to the next layer.
   virtual bool      UpdateInputWeights(CObject *SourceObject);               ///< Dispatch method for defining the subroutine for updating weights.@param SourceObject Pointer to previos layer.
   ///\ingroup neuron_base_gr
   ///@{
   virtual bool      calcHiddenGradients(CNeuronBaseOCL *NeuronOCL);          ///< Method to transfer gradient to previous layer by calling kernel ::CalcHiddenGradient(). @param NeuronOCL Pointer to next layer.
   virtual bool      calcOutputGradients(CArrayFloat *Target, float error);               ///< Method of output gradients calculation by calling kernel ::CalcOutputGradient().@param Target Traget value
   ///@}
   //---
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   //---
   virtual int       Type(void)        const                      {  return defNeuronBaseOCL;                  }///< Identificator of class.@return Type of class
   virtual void      TrainMode(bool flag)                         {  bTrain = flag;                              } ///< Set Training Mode Flag
   virtual bool      TrainMode(void)                              {  return bTrain;                            }///< Get Training Mode Flag
   virtual CLayerDescription* GetLayerInfo(void);
   virtual bool      numOutputs(const uint outputs, ENUM_OPTIMIZATION optimization_type);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronBaseOCL::CNeuronBaseOCL(void)   :  alpha(momentum),
   activation(TANH),
   optimization(SGD),
   t(1),
   bTrain(true)
  {
   OpenCL = NULL;
   Output = new CBufferFloat();
   PrevOutput = new CBufferFloat();
   Weights = new CBufferFloat();
   DeltaWeights = new CBufferFloat();
   Gradient = new CBufferFloat();
   FirstMomentum = new CBufferFloat();
   SecondMomentum = new CBufferFloat();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronBaseOCL::~CNeuronBaseOCL(void)
  {
   if(CheckPointer(Output) != POINTER_INVALID)
      delete Output;
   if(CheckPointer(PrevOutput) != POINTER_INVALID)
      delete PrevOutput;
   if(CheckPointer(Weights) != POINTER_INVALID)
      delete Weights;
   if(CheckPointer(DeltaWeights) != POINTER_INVALID)
      delete DeltaWeights;
   if(CheckPointer(Gradient) != POINTER_INVALID)
      delete Gradient;
   if(CheckPointer(FirstMomentum) != POINTER_INVALID)
      delete FirstMomentum;
   if(CheckPointer(SecondMomentum) != POINTER_INVALID)
      delete SecondMomentum;
   OpenCL = NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(CheckPointer(open_cl) == POINTER_INVALID || numNeurons <= 0)
      return false;
   OpenCL = open_cl;
   optimization = optimization_type;
   iBatch = batch;
//---
   if(CheckPointer(Output) == POINTER_INVALID)
     {
      Output = new CBufferFloat();
      if(CheckPointer(Output) == POINTER_INVALID)
         return false;
     }
   if(!Output.BufferInit(numNeurons, 1.0))
      return false;
   if(!Output.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(PrevOutput) == POINTER_INVALID)
     {
      PrevOutput = new CBufferFloat();
      if(CheckPointer(PrevOutput) == POINTER_INVALID)
         return false;
     }
   if(!PrevOutput.BufferInit(numNeurons, 1.0))
      return false;
   if(!PrevOutput.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(Gradient) == POINTER_INVALID)
     {
      Gradient = new CBufferFloat();
      if(CheckPointer(Gradient) == POINTER_INVALID)
         return false;
     }
   if(!Gradient.BufferInit(numNeurons + 1, 0.0))
      return false;
   if(!Gradient.BufferCreate(OpenCL))
      return false;
//---
   if(numOutputs > 0)
     {
      if(CheckPointer(Weights) == POINTER_INVALID)
        {
         Weights = new CBufferFloat();
         if(CheckPointer(Weights) == POINTER_INVALID)
            return false;
        }
      int count = (int)((numNeurons + 1) * numOutputs);
      if(!Weights.Reserve(count))
         return false;
      float k = (float)(1 / sqrt(numNeurons + 1));
      for(int i = 0; i < count; i++)
        {
         if(!Weights.Add((2 * GenerateWeight()*k - k)*WeightsMultiplier))
            return false;
        }
      if(!Weights.BufferCreate(OpenCL))
         return false;
      //---
      if(optimization == SGD)
        {
         if(CheckPointer(DeltaWeights) == POINTER_INVALID)
           {
            DeltaWeights = new CBufferFloat();
            if(CheckPointer(DeltaWeights) == POINTER_INVALID)
               return false;
           }
         if(!DeltaWeights.BufferInit(count, 0))
            return false;
         if(!DeltaWeights.BufferCreate(OpenCL))
            return false;
         if(CheckPointer(FirstMomentum) != POINTER_INVALID)
            delete FirstMomentum;
         if(CheckPointer(SecondMomentum) != POINTER_INVALID)
            delete SecondMomentum;
        }
      else
        {
         if(CheckPointer(DeltaWeights) != POINTER_INVALID)
            delete DeltaWeights;
         //---
         if(CheckPointer(FirstMomentum) == POINTER_INVALID)
           {
            FirstMomentum = new CBufferFloat();
            if(CheckPointer(FirstMomentum) == POINTER_INVALID)
               return false;
           }
         if(!FirstMomentum.BufferInit(count, 0))
            return false;
         if(!FirstMomentum.BufferCreate(OpenCL))
            return false;
         //---
         if(CheckPointer(SecondMomentum) == POINTER_INVALID)
           {
            SecondMomentum = new CBufferFloat();
            if(CheckPointer(SecondMomentum) == POINTER_INVALID)
               return false;
           }
         if(!SecondMomentum.BufferInit(count, 0))
            return false;
         if(!SecondMomentum.BufferCreate(OpenCL))
            return false;
        }
     }
   else
     {
      if(CheckPointer(Weights) != POINTER_INVALID)
         delete Weights;
      if(CheckPointer(DeltaWeights) != POINTER_INVALID)
         delete DeltaWeights;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::FeedForward(CObject *SourceObject)
  {
   if(CheckPointer(SourceObject) == POINTER_INVALID)
      return false;
//---
   CNeuronBaseOCL *temp = NULL;
   switch(SourceObject.Type())
     {
      case defNeuronBaseOCL:
      case defNeuronConvOCL:
      case defNeuronAttentionOCL:
      case defNeuronMHAttentionOCL:
      case defNeuronMLMHAttentionOCL:
      case defNeuronDropoutOCL:
      case defNeuronBatchNormOCL:
      case defNeuronVAEOCL:
      case defNeuronLSTMOCL:
         temp = SourceObject;
         return feedForward(temp);
         break;
     }
//---
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Output.Total();
   OpenCL.SetArgumentBuffer(def_k_FeedForward, def_k_ff_matrix_w, NeuronOCL.getWeightsIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForward, def_k_ff_matrix_i, NeuronOCL.getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForward, def_k_ff_matrix_o, Output.GetIndex());
   OpenCL.SetArgument(def_k_FeedForward, def_k_ff_inputs, NeuronOCL.Neurons());
   OpenCL.SetArgument(def_k_FeedForward, def_k_ff_activation, (int)activation);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_FeedForward, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel FeedForward: %d", GetLastError());
      return false;
     }
   float temp[];
   if(!Output.BufferRead())
     {
      NeuronOCL.Weights.BufferToCSV("weights.csv");
      NeuronOCL.Output.BufferToCSV("inputs.csv");
      Output.BufferToCSV("output.csv");
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::calcHiddenGradients(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Neurons();
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_k_chg_matrix_w, getWeightsIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_k_chg_matrix_g, NeuronOCL.getGradientIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_k_chg_matrix_o, getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_k_chg_matrix_ig, getGradientIndex());
   OpenCL.SetArgument(def_k_CalcHiddenGradient, def_k_chg_outputs, NeuronOCL.Neurons());
   OpenCL.SetArgument(def_k_CalcHiddenGradient, def_k_chg_activation, Activation());
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_CalcHiddenGradient, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel CalcHiddenGradient: %d", GetLastError());
      return false;
     }
//if(!Gradient.BufferRead())
//   return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::calcOutputGradients(CArrayFloat *target, float error)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(target) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = target.Total();
   for(uint i = 0; i < global_work_size[0]; i++)
      if(!Gradient.Update(i, target.At(i)))
         return false;
   Gradient.BufferWrite();
   OpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_k_cog_matrix_t, getGradientIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_k_cog_matrix_o, getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_k_cog_matrix_ig, getGradientIndex());
   OpenCL.SetArgument(def_k_CalcOutputGradient, def_k_cog_activation, (int)activation);
   OpenCL.SetArgument(def_k_CalcOutputGradient, def_k_cog_error, error);
   ResetLastError();
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_CalcOutputGradient, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel CalcOutputGradient: %d", GetLastError());
      return false;
     }
//Gradient.BufferRead();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::updateInputWeights(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[2] = {0, 0};
   uint global_work_size[2];
   global_work_size[0] = Neurons();
   global_work_size[1] = NeuronOCL.Neurons();
   uint rest = 0;
   float lt = lr;
   switch(optimization)
     {
      case SGD:
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsMomentum, def_k_uwm_matrix_w, NeuronOCL.getWeightsIndex());
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsMomentum, def_k_uwm_matrix_g, getGradientIndex());
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsMomentum, def_k_uwm_matrix_i, NeuronOCL.getOutputIndex());
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsMomentum, def_k_uwm_matrix_dw, NeuronOCL.getDeltaWeightsIndex());
         OpenCL.SetArgument(def_k_UpdateWeightsMomentum, def_k_uwm_inputs, NeuronOCL.Neurons());
         OpenCL.SetArgument(def_k_UpdateWeightsMomentum, def_k_uwm_learning_rates, eta);
         OpenCL.SetArgument(def_k_UpdateWeightsMomentum, def_k_uwm_momentum, alpha);
         ResetLastError();
         //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
         if(!OpenCL.Execute(def_k_UpdateWeightsMomentum, 2, global_work_offset, global_work_size))
           {
            printf("Error of execution kernel UpdateWeightsMomentum: %d", GetLastError());
            return false;
           }
         break;
      case ADAM:
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsAdam, def_k_uwa_matrix_w, NeuronOCL.getWeightsIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsAdam, def_k_uwa_matrix_g, getGradientIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsAdam, def_k_uwa_matrix_i, NeuronOCL.getOutputIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsAdam, def_k_uwa_matrix_m, NeuronOCL.getFirstMomentumIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsAdam, def_k_uwa_matrix_v, NeuronOCL.getSecondMomentumIndex()))
            return false;
         lt = (float)(eta * sqrt(1 - pow(b2, (float)t)) / (1 - pow(b1, (float)t)));
         if(!OpenCL.SetArgument(def_k_UpdateWeightsAdam, def_k_uwa_inputs, NeuronOCL.Neurons()))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsAdam, def_k_uwa_l, lt))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsAdam, def_k_uwa_b1, b1))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsAdam, def_k_uwa_b2, b2))
            return false;
         rest = global_work_size[1] % 4;
         global_work_size[1] = (global_work_size[1] - rest) / 4 + (rest > 0 ? 1 : 0);
         ////Comment(com+"\n UpdateWeightsAdam");
         ResetLastError();
         //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
         if(!OpenCL.Execute(def_k_UpdateWeightsAdam, 2, global_work_offset, global_work_size))
           {
            printf("Error of execution kernel UpdateWeightsAdam: %d", GetLastError());
            return false;
           }
         t++;
         break;
      case LS:
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsLS, def_k_uwls_matrix_w, NeuronOCL.getWeightsIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsLS, def_k_uwls_matrix_g, getGradientIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsLS, def_k_uwls_matrix_i, NeuronOCL.getOutputIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsLS, def_k_uwls_matrix_xg, NeuronOCL.getFirstMomentumIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsLS, def_k_uwls_matrix_xx, NeuronOCL.getSecondMomentumIndex()))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsLS, def_k_uwls_inputs, NeuronOCL.Neurons()))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsLS, def_k_uwls_l, lr))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsLS, def_k_uwls_update, (int)(t >= iBatch)))
            return false;
         rest = global_work_size[1] % 4;
         global_work_size[1] = (global_work_size[1] - rest) / 4 + (rest > 0 ? 1 : 0);
         ////Comment(com+"\n UpdateWeightsAdam");
         ResetLastError();
         //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
         if(!OpenCL.Execute(def_k_UpdateWeightsLS, 2, global_work_offset, global_work_size))
           {
            printf("Error of execution kernel UpdateWeightsLS: %d", GetLastError());
            return false;
           }
         if(t >= iBatch)
            t = 0;
         else
            t++;
         break;
      default:
         return false;
         break;
     }
//---
   return true;//NeuronOCL.Weights.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::calcHiddenGradients(CObject *TargetObject)
  {
//---
   if(CheckPointer(TargetObject) == POINTER_INVALID)
      return false;
//---
   CNeuronBaseOCL *temp = NULL;
   CNeuronAttentionOCL *at = NULL;
   CNeuronMLMHAttentionOCL *mlat = NULL;
   CNeuronProofOCL *conv = NULL;
   CNeuronDropoutOCL *dropout = NULL;
   CNeuronBatchNormOCL *batch = NULL;
   CVAE *vae = NULL;
   CNeuronLSTMOCL *lstm = NULL;
   switch(TargetObject.Type())
     {
      case defNeuronBaseOCL:
         temp = TargetObject;
         if(!bTrain && !temp.TrainMode())
            return true;
         return calcHiddenGradients(temp);
         break;
      case defNeuronConvOCL:
      case defNeuronProofOCL:
         conv = TargetObject;
         if(!bTrain && !conv.TrainMode())
            return true;
         temp = GetPointer(this);
         return conv.calcInputGradients(temp);
         break;
      case defNeuronAttentionOCL:
      case defNeuronMHAttentionOCL:
         at = TargetObject;
         if(!bTrain && !at.TrainMode())
            return true;
         temp = GetPointer(this);
         return at.calcInputGradients(temp);
         break;
      case defNeuronMLMHAttentionOCL:
         mlat = TargetObject;
         if(!bTrain && !mlat.TrainMode())
            return true;
         temp = GetPointer(this);
         return mlat.calcInputGradients(temp);
         break;
      case defNeuronDropoutOCL:
         dropout = TargetObject;
         if(!bTrain && !dropout.TrainMode())
            return true;
         temp = GetPointer(this);
         return dropout.calcInputGradients(temp);
         break;
      case defNeuronBatchNormOCL:
         batch = TargetObject;
         if(!bTrain && !batch.TrainMode())
            return true;
         temp = GetPointer(this);
         return batch.calcInputGradients(temp);
         break;
      case defNeuronVAEOCL:
         vae = TargetObject;
         temp = GetPointer(this);
         return vae.calcInputGradients(temp);
         break;
      case defNeuronLSTMOCL:
         lstm = TargetObject;
         if(!bTrain && !lstm.TrainMode())
            return true;
         temp = GetPointer(this);
         return lstm.calcInputGradients(temp);
         break;
     }
//---
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::UpdateInputWeights(CObject *SourceObject)
  {
//---
   if(CheckPointer(SourceObject) == POINTER_INVALID)
      return false;
//---
   CNeuronBaseOCL *temp = NULL;
   switch(SourceObject.Type())
     {
      case defNeuronBaseOCL:
      case defNeuronConvOCL:
      case defNeuronProofOCL:
      case defNeuronAttentionOCL:
      case defNeuronMHAttentionOCL:
      case defNeuronMLMHAttentionOCL:
      case defNeuronDropoutOCL:
      case defNeuronBatchNormOCL:
      case defNeuronVAEOCL:
      case defNeuronLSTMOCL:
         temp = SourceObject;
         if(!bTrain && !temp.TrainMode())
            return true;
         return updateInputWeights(temp);
         break;
     }
//---
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::Save(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
   if(FileWriteInteger(file_handle, Type()) < INT_VALUE)
      return false;
//---
   if(FileWriteInteger(file_handle, (int)activation, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, (int)optimization, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, (int)iBatch, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, (int)t, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, (int)bTrain, INT_VALUE) < INT_VALUE)
      return false;
//---
   if(CheckPointer(Output) == POINTER_INVALID || !Output.BufferRead() || !Output.Save(file_handle))
      return false;
   if(CheckPointer(PrevOutput) == POINTER_INVALID || !PrevOutput.BufferRead() || !PrevOutput.Save(file_handle))
      return false;
   if(CheckPointer(Gradient) == POINTER_INVALID || !Gradient.BufferRead() || !Gradient.Save(file_handle))
      return false;
//---
   if(CheckPointer(Weights) == POINTER_INVALID)
     {
      FileWriteInteger(file_handle, 0);
      return true;
     }
   else
      FileWriteInteger(file_handle, 1);
//---
   if(CheckPointer(Weights) == POINTER_INVALID || !Weights.BufferRead() || !Weights.Save(file_handle))
      return false;
   if(optimization == SGD)
     {
      if(CheckPointer(DeltaWeights) == POINTER_INVALID || !DeltaWeights.BufferRead() || !DeltaWeights.Save(file_handle))
         return false;
     }
   else
     {
      if(CheckPointer(FirstMomentum) == POINTER_INVALID || !FirstMomentum.BufferRead() || !FirstMomentum.Save(file_handle))
         return false;
      if(CheckPointer(SecondMomentum) == POINTER_INVALID || !SecondMomentum.BufferRead() || !SecondMomentum.Save(file_handle))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::Load(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
//---
   activation = (ENUM_ACTIVATION)FileReadInteger(file_handle, INT_VALUE);
   optimization = (ENUM_OPTIMIZATION)FileReadInteger(file_handle, INT_VALUE);
   iBatch = (uint)FileReadInteger(file_handle, INT_VALUE);
   t = (uint)FileReadInteger(file_handle, INT_VALUE);
   bTrain = (bool)FileReadInteger(file_handle, INT_VALUE);
   if(CheckPointer(Output) == POINTER_INVALID)
     {
      Output = new CBufferFloat();
      if(CheckPointer(Output) == POINTER_INVALID)
         return false;
     }
   if(Output.GetIndex() >= 0)
      Output.BufferFree();
   if(!Output.Load(file_handle))
      return false;
   if(!Output.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(PrevOutput) == POINTER_INVALID)
     {
      PrevOutput = new CBufferFloat();
      if(CheckPointer(PrevOutput) == POINTER_INVALID)
         return false;
     }
   if(PrevOutput.GetIndex() >= 0)
      PrevOutput.BufferFree();
   if(!PrevOutput.Load(file_handle))
      return false;
   if(!PrevOutput.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(Gradient) == POINTER_INVALID)
     {
      Gradient = new CBufferFloat();
      if(CheckPointer(Gradient) == POINTER_INVALID)
         return false;
     }
   if(Gradient.GetIndex() >= 0)
      Gradient.BufferFree();
   if(!Gradient.Load(file_handle))
      return false;
   if(!Gradient.BufferCreate(OpenCL))
      return false;
//---
   if(FileReadInteger(file_handle) == 0)
      return true;
//---
   if(CheckPointer(Weights) == POINTER_INVALID)
     {
      Weights = new CBufferFloat();
      if(CheckPointer(Weights) == POINTER_INVALID)
         return false;
     }
   if(Weights.GetIndex() >= 0)
      Weights.BufferFree();
   if(!Weights.Load(file_handle))
      return false;
   if(!Weights.BufferCreate(OpenCL))
      return false;
//---
   if(optimization == SGD)
     {
      if(CheckPointer(DeltaWeights) == POINTER_INVALID)
        {
         DeltaWeights = new CBufferFloat();
         if(CheckPointer(DeltaWeights) == POINTER_INVALID)
            return false;
        }
      if(DeltaWeights.GetIndex() >= 0)
         DeltaWeights.BufferFree();
      if(!DeltaWeights.Load(file_handle))
         return false;
      if(!DeltaWeights.BufferCreate(OpenCL))
         return false;
     }
   else
     {
      if(CheckPointer(FirstMomentum) == POINTER_INVALID)
        {
         FirstMomentum = new CBufferFloat();
         if(CheckPointer(FirstMomentum) == POINTER_INVALID)
            return false;
        }
      if(FirstMomentum.GetIndex() >= 0)
         FirstMomentum.BufferFree();
      if(!FirstMomentum.Load(file_handle))
         return false;
      if(!FirstMomentum.BufferCreate(OpenCL))
         return false;
      //---
      if(CheckPointer(SecondMomentum) == POINTER_INVALID)
        {
         SecondMomentum = new CBufferFloat();
         if(CheckPointer(SecondMomentum) == POINTER_INVALID)
            return false;
        }
      if(SecondMomentum.GetIndex() >= 0)
         SecondMomentum.BufferFree();
      if(!SecondMomentum.Load(file_handle))
         return false;
      if(!SecondMomentum.BufferCreate(OpenCL))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronBaseOCL::GetLayerInfo(void)
  {
   CLayerDescription* result = new CLayerDescription();
   if(!result)
      return result;
//---
   result.type = Type();
   result.count = Output.Total();
   result.optimization = optimization;
   result.activation = activation;
   result.batch = (int)(optimization == LS ? iBatch : 1);
   result.layers = 1;
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBaseOCL::numOutputs(const uint outputs, ENUM_OPTIMIZATION optimization_type)
  {
   if(outputs > 0)
     {
      if(CheckPointer(Weights) == POINTER_INVALID)
        {
         Weights = new CBufferFloat();
         if(CheckPointer(Weights) == POINTER_INVALID)
            return false;
        }
      Weights.BufferFree();
      Weights.Clear();
      int count = (int)((Output.Total() + 1) * outputs);
      if(!Weights.Reserve(count))
         return false;
      float k = (float)(1 / sqrt(Output.Total() + 1));
      for(int i = 0; i < count; i++)
        {
         if(!Weights.Add((2 * GenerateWeight()*k - k)*WeightsMultiplier))
            return false;
        }
      if(!Weights.BufferCreate(OpenCL))
         return false;
      //---
      if(optimization_type == SGD)
        {
         if(CheckPointer(DeltaWeights) == POINTER_INVALID)
           {
            DeltaWeights = new CBufferFloat();
            if(CheckPointer(DeltaWeights) == POINTER_INVALID)
               return false;
           }
         DeltaWeights.BufferFree();
         if(!DeltaWeights.BufferInit(count, 0))
            return false;
         if(!DeltaWeights.BufferCreate(OpenCL))
            return false;
         if(CheckPointer(FirstMomentum) != POINTER_INVALID)
           {
            FirstMomentum.BufferFree();
            delete FirstMomentum;
           }
         if(CheckPointer(SecondMomentum) != POINTER_INVALID)
           {
            SecondMomentum.BufferFree();
            delete SecondMomentum;
           }
        }
      else
        {
         if(CheckPointer(DeltaWeights) != POINTER_INVALID)
           {
            DeltaWeights.BufferFree();
            delete DeltaWeights;
           }
         //---
         if(CheckPointer(FirstMomentum) == POINTER_INVALID)
           {
            FirstMomentum = new CBufferFloat();
            if(CheckPointer(FirstMomentum) == POINTER_INVALID)
               return false;
           }
         FirstMomentum.BufferFree();
         if(!FirstMomentum.BufferInit(count, 0))
            return false;
         if(!FirstMomentum.BufferCreate(OpenCL))
            return false;
         //---
         if(CheckPointer(SecondMomentum) == POINTER_INVALID)
           {
            SecondMomentum = new CBufferFloat();
            if(CheckPointer(SecondMomentum) == POINTER_INVALID)
               return false;
           }
         SecondMomentum.BufferFree();
         if(!SecondMomentum.BufferInit(count, 0))
            return false;
         if(!SecondMomentum.BufferCreate(OpenCL))
            return false;
        }
     }
   else
     {
      if(CheckPointer(Weights) != POINTER_INVALID)
        {
         Weights.BufferFree();
         delete Weights;
        }
      if(CheckPointer(DeltaWeights) != POINTER_INVALID)
        {
         DeltaWeights.BufferFree();
         delete DeltaWeights;
        }
      if(CheckPointer(FirstMomentum) != POINTER_INVALID)
        {
         FirstMomentum.BufferFree();
         delete FirstMomentum;
        }
      if(CheckPointer(SecondMomentum) != POINTER_INVALID)
        {
         SecondMomentum.BufferFree();
         delete SecondMomentum;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
///\class CNeuronProofOCL
/// Class of pooling layer GPU calculation
//+------------------------------------------------------------------+
class CNeuronProofOCL : public CNeuronBaseOCL
  {
protected:
   uint               iWindow;                                             ///< Input window size
   uint               iStep;                                               ///< Size of step

   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL);               ///< Feed Forward method.@param NeuronOCL Pointer to previos layer.

public:
   /** Constructor */
                     CNeuronProofOCL(void) : iWindow(2), iStep(1) {};
   /** Destructor */~CNeuronProofOCL(void);
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, int window, int step, int units_count, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object.@param[in] window Size of input window @param[in] step Step size.@param[in] units_countNumber of neurons.@param[in] optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   //---
   virtual bool      calcInputGradients(CNeuronBaseOCL *NeuronOCL);        ///< Method to transfer gradients to previous layer @param[in] NeuronOCL Pointer to previous layer.
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL)   { return true;};        ///< Method for updating weights.\details Calling one of kernels ::UpdateWeightsMomentum() or ::UpdateWeightsAdam() in depends of optimization type (#ENUM_OPTIMIZATION).@param NeuronOCL Pointer to previos layer.
   //--- methods for working with files
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual int       Type(void)   const   {  return defNeuronProofOCL;   }///< Identificator of class.@return Type of class
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProofOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, int window, int step, int units_count, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   iWindow = window;
   iStep = step;
   if(!CNeuronBaseOCL::Init(numOutputs, myIndex, open_cl, units_count, optimization_type, batch))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronProofOCL::~CNeuronProofOCL(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProofOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Output.Total();
   OpenCL.SetArgumentBuffer(def_k_FeedForwardProof, def_k_ffp_matrix_i, NeuronOCL.getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForwardProof, def_k_ffp_matrix_o, Output.GetIndex());
   OpenCL.SetArgument(def_k_FeedForwardProof, def_k_ffp_inputs, NeuronOCL.Neurons());
   OpenCL.SetArgument(def_k_FeedForwardProof, def_k_ffp_window, iWindow);
   OpenCL.SetArgument(def_k_FeedForwardProof, def_k_ffp_step, iStep);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_FeedForwardProof, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel FeedForwardProof: %d", GetLastError());
      return false;
     }
//---
   return Output.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProofOCL::calcInputGradients(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = NeuronOCL.Neurons();
   OpenCL.SetArgumentBuffer(def_k_CalcInputGradientProof, def_k_cigp_matrix_i, NeuronOCL.getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcInputGradientProof, def_k_cigp_matrix_o, Output.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcInputGradientProof, def_k_cigp_matrix_g, Gradient.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcInputGradientProof, def_k_cigp_matrix_ig, NeuronOCL.getGradientIndex());
   OpenCL.SetArgument(def_k_CalcInputGradientProof, def_k_cigp_outputs, Output.Total());
   OpenCL.SetArgument(def_k_CalcInputGradientProof, def_k_cigp_window, iWindow);
   OpenCL.SetArgument(def_k_CalcInputGradientProof, def_k_cigp_step, iStep);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_CalcInputGradientProof, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel CalcInputGradientProof: %d", GetLastError());
      return false;
     }
//---
   float temp[];
   return NeuronOCL.getGradient(temp) > 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronProofOCL::GetLayerInfo(void)
  {
   CLayerDescription *result = CNeuronBaseOCL::GetLayerInfo();
   if(!result)
      return result;
   result.window = (int)iWindow;
   result.step = (int)iStep;
//---
   return result;
  }
//+------------------------------------------------------------------+
///\class CNeuronConvOCL
/// Class of convolution layer GPU calculation
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para41">the link.</A>
//+------------------------------------------------------------------+
class CNeuronConvOCL    :  public CNeuronProofOCL
  {
protected:
   uint              iWindowOut;                                           ///< Size of out window
   //---
   CBufferFloat      *WeightsConv;                                         ///< Matrix of weights to previous layer
   CBufferFloat      *DeltaWeightsConv;                                    ///< Matrix of delta weights to previous layer (#SGD)
   CBufferFloat      *FirstMomentumConv;                                   ///< Matrix of first momentum to previous layer (#ADAM)
   CBufferFloat      *SecondMomentumConv;                                  ///< Matrix of second momentum to previous layer (#ADAM)
   //---
   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL);               ///< Feed Forward method.@param NeuronOCL Pointer to previos layer.
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL);        ///< Method for updating weights.@param NeuronOCL Pointer to previos layer.

public:
   /** Constructor */
                     CNeuronConvOCL(void) :   iWindowOut(1) {  activation = LReLU;   }
   /** Destructor */~CNeuronConvOCL(void);
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint step, uint window_out, uint units_count, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object.@param[in] window Size of input window @param[in] step Step size.@param[in] window_out Size of output window @param[in] units_countNumber of neurons.@param[in] optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   //---
   virtual bool      SetGradientIndex(int index)   {  return Gradient.BufferSet(index);   }  ///< Method for change index of gradient buffer.@param[in] New index of buffer
   //---
   virtual bool      calcInputGradients(CNeuronBaseOCL *NeuronOCL);        ///< Method to transfer gradients to previous layer @param[in] NeuronOCL Pointer to previous layer.
   virtual int       Type(void)   const   {  return defNeuronConvOCL;   }///< Identificator of class.@return Type of class
   //--- methods for working with files
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   //---
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronConvOCL::~CNeuronConvOCL(void)
  {
   if(CheckPointer(WeightsConv) != POINTER_INVALID)
      delete WeightsConv;
   if(CheckPointer(DeltaWeightsConv) != POINTER_INVALID)
      delete DeltaWeightsConv;
   if(CheckPointer(FirstMomentumConv) != POINTER_INVALID)
      delete FirstMomentumConv;
   if(CheckPointer(SecondMomentumConv) != POINTER_INVALID)
      delete SecondMomentumConv;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConvOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window_in, uint step, uint window_out, uint units_count, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(window_out <= 0 || (optimization == LS && batch <= 0))
      return false;
   if(!CNeuronProofOCL::Init(numOutputs, myIndex, open_cl, window_in, step, units_count * window_out, optimization_type, batch))
      return false;
//---
   iWindowOut = fmax(window_out, 1);
//---
   if(CheckPointer(WeightsConv) == POINTER_INVALID)
     {
      WeightsConv = new CBufferFloat();
      if(CheckPointer(WeightsConv) == POINTER_INVALID)
         return false;
     }
   int count = (int)((iWindow + 1) * iWindowOut);
   if(!WeightsConv.Reserve(count))
      return false;
   float k = (float)(1 / sqrt(iWindow + 1));
   for(int i = 0; i < count; i++)
     {
      if(!WeightsConv.Add((GenerateWeight() * 2 * k - k)*WeightsMultiplier))
         return false;
     }
   if(!WeightsConv.BufferCreate(OpenCL))
      return false;
//---
   if(optimization == SGD)
     {
      if(CheckPointer(DeltaWeightsConv) == POINTER_INVALID)
        {
         DeltaWeightsConv = new CBufferFloat();
         if(CheckPointer(DeltaWeightsConv) == POINTER_INVALID)
            return false;
        }
      if(!DeltaWeightsConv.BufferInit(count, 0.0))
         return false;
      if(!DeltaWeightsConv.BufferCreate(OpenCL))
         return false;
     }
   else
     {
      if(CheckPointer(FirstMomentumConv) == POINTER_INVALID)
        {
         FirstMomentumConv = new CBufferFloat();
         if(CheckPointer(FirstMomentumConv) == POINTER_INVALID)
            return false;
        }
      if(!FirstMomentumConv.BufferInit(count, 0.0))
         return false;
      if(!FirstMomentumConv.BufferCreate(OpenCL))
         return false;
      //---
      if(CheckPointer(SecondMomentumConv) == POINTER_INVALID)
        {
         SecondMomentumConv = new CBufferFloat();
         if(CheckPointer(SecondMomentumConv) == POINTER_INVALID)
            return false;
        }
      if(!SecondMomentumConv.BufferInit(count, 0.0))
         return false;
      if(!SecondMomentumConv.BufferCreate(OpenCL))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConvOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Output.Total() / iWindowOut;
   OpenCL.SetArgumentBuffer(def_k_FeedForwardConv, def_k_ffc_matrix_w, WeightsConv.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForwardConv, def_k_ffc_matrix_i, NeuronOCL.getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForwardConv, def_k_ffc_matrix_o, Output.GetIndex());
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_inputs, NeuronOCL.Neurons());
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_step, iStep);
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_window_in, iWindow);
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffс_window_out, iWindowOut);
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_activation, (int)activation);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_FeedForwardConv, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel FeedForwardConv: %d", GetLastError());
      return false;
     }
//---
   return Output.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConvOCL::calcInputGradients(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = NeuronOCL.Neurons();
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_w, WeightsConv.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_g, Gradient.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_o, NeuronOCL.getOutputIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_ig, NeuronOCL.getGradientIndex());
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_outputs, Neurons());
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_step, iStep);
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_window_in, iWindow);
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_window_out, iWindowOut);
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_activation, NeuronOCL.Activation());
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_CalcHiddenGradientConv, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel CalcHiddenGradientConv: %d", GetLastError());
      return false;
     }
//---
   float temp[];
   return NeuronOCL.getGradient(temp) > 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConvOCL::updateInputWeights(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = WeightsConv.Total();
   float lt = 0;
   switch(optimization)
     {
      case SGD:
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_w, WeightsConv.GetIndex());
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_g, getGradientIndex());
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_i, NeuronOCL.getOutputIndex());
         OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_dw, DeltaWeightsConv.GetIndex());
         OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_inputs, NeuronOCL.Neurons());
         OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_learning_rates, eta);
         OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_momentum, alpha);
         OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_window_in, iWindow);
         OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_window_out, iWindowOut);
         OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_step, iStep);
         ResetLastError();
         //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
         if(!OpenCL.Execute(def_k_UpdateWeightsConvMomentum, 1, global_work_offset, global_work_size))
           {
            printf("Error of execution kernel UpdateWeightsConvMomentum: %d", GetLastError());
            return false;
           }
         break;
      case ADAM:
         global_work_size[0] = iWindow + 1;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_w, WeightsConv.GetIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_g, getGradientIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_i, NeuronOCL.getOutputIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_m, FirstMomentumConv.GetIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_v, SecondMomentumConv.GetIndex()))
            return false;
         lt = (float)(eta * sqrt(1 - pow(b2, t)) / (1 - pow(b1, t)));
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwa_inputs, NeuronOCL.Neurons()))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_l, lt))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_b1, b1))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_b2, b2))
            return false;
         OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_window_in, iWindow);
         OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_window_out, iWindowOut);
         OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_step, iStep);
         ResetLastError();
         //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
         if(!OpenCL.Execute(def_k_UpdateWeightsConvAdam, 1, global_work_offset, global_work_size))
           {
            printf("Error of execution kernel UpdateWeightsConvAdam: %d", GetLastError());
            return false;
           }
         t++;
         break;
      case LS:
         global_work_size[0] = iWindow + 1;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvLS, def_k_uwcls_matrix_w, WeightsConv.GetIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvLS, def_k_uwcls_matrix_g, getGradientIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvLS, def_k_uwcls_matrix_i, NeuronOCL.getOutputIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvLS, def_k_uwcls_matrix_xg, FirstMomentumConv.GetIndex()))
            return false;
         if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvLS, def_k_uwcls_matrix_xx, SecondMomentumConv.GetIndex()))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvLS, def_k_uwls_inputs, NeuronOCL.Neurons()))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvLS, def_k_uwcls_l, lr))
            return false;
         if(!OpenCL.SetArgument(def_k_UpdateWeightsConvLS, def_k_uwcls_update, (int)(t >= iBatch)))
            return false;
         OpenCL.SetArgument(def_k_UpdateWeightsConvLS, def_k_uwcls_window_in, iWindow);
         OpenCL.SetArgument(def_k_UpdateWeightsConvLS, def_k_uwcls_window_out, iWindowOut);
         OpenCL.SetArgument(def_k_UpdateWeightsConvLS, def_k_uwcls_step, iStep);
         ResetLastError();
         //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
         if(!OpenCL.Execute(def_k_UpdateWeightsConvLS, 1, global_work_offset, global_work_size))
           {
            printf("Error of execution kernel UpdateWeightsConvLS: %d", GetLastError());
            return false;
           }
         if(t >= iBatch)
            t = 0;
         else
            t++;
         break;
      default:
         return false;
         break;
     }
//---
//if(WeightsConv.BufferRead())
//  {
//   //---
//   global_work_size[0]=1;
//   OpenCL.SetArgumentBuffer(def_k_NormilizeWeights,def_k_norm_buffer,WeightsConv.GetIndex());
//   OpenCL.SetArgument(def_k_NormilizeWeights,def_k_norm_dimension,WeightsConv.Total());
//   //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
//   if(!OpenCL.Execute(def_k_NormilizeWeights,1,global_work_offset,global_work_size))
//     {
//      printf("Error of execution kernel Normalize: %d",GetLastError());
//      return false;
//     }
//  }
//else
//  {
//   return false;
//  }
   return WeightsConv.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronConvOCL::GetLayerInfo(void)
  {
   CLayerDescription *result = CNeuronProofOCL::GetLayerInfo();
   if(!result)
      return result;
   result.window_out = (int)iWindowOut;
   result.count /= (int)iWindowOut;
//---
   return result;
  }
//+------------------------------------------------------------------+
///\class CNeuronAttentionOCL
/// Class of Self-Attention layer GPU calculation
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8765#para42">the link.</A>
//+------------------------------------------------------------------+
class CNeuronAttentionOCL : public CNeuronBaseOCL
  {
protected:
   CNeuronConvOCL    *Querys;             ///< Convolution layer for Querys
   CNeuronConvOCL    *Keys;               ///< Convolution layer for Keys
   CNeuronConvOCL    *Values;             ///< Convolution layer for Values
   CBufferFloat      *Scores;             ///< Buffer for Scores matrix
   CNeuronBaseOCL    *AttentionOut;       ///< Layer of Self-Attention Out
   CNeuronConvOCL    *FF1;                ///< Convolution layer for first layer of Feed Forward block
   CNeuronConvOCL    *FF2;                ///< Convolution layer for second layer of Feed Forward block
   //---
   uint              iWindow;             ///< Window size
   uint              iUnits;              ///< Number of units
   //---
   virtual bool      feedForward(CNeuronBaseOCL *prevLayer);                  ///< Feed Forward method.@param prevLayer Pointer to previos layer.
   virtual bool      updateInputWeights(CNeuronBaseOCL *prevLayer);           ///< Method for updating weights.@param prevLayer Pointer to previos layer.

public:
   /** Constructor */
                     CNeuronAttentionOCL(void) : iWindow(1), iUnits(0) {};
   /** Destructor */~CNeuronAttentionOCL(void);
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint units_count, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object.@param[in] window Size of in/out window and step.@param[in] units_countNumber of neurons.@param[in] optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   virtual bool      calcInputGradients(CNeuronBaseOCL *prevLayer);  ///< Method to transfer gradients to previous layer @param[in] prevLayer Pointer to previous layer.
   //---
   virtual int       Type(void)   const   {  return defNeuronAttentionOCL;   }///< Identificator of class.@return Type of class
   //--- methods for working with files
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronAttentionOCL::~CNeuronAttentionOCL(void)
  {
   if(CheckPointer(Querys) != POINTER_INVALID)
      delete Querys;
   if(CheckPointer(Keys) != POINTER_INVALID)
      delete Keys;
   if(CheckPointer(Values) != POINTER_INVALID)
      delete Values;
   if(CheckPointer(Scores) != POINTER_INVALID)
      delete Scores;
   if(CheckPointer(AttentionOut) != POINTER_INVALID)
      delete AttentionOut;
   if(CheckPointer(FF1) != POINTER_INVALID)
      delete FF1;
   if(CheckPointer(FF2) != POINTER_INVALID)
      delete FF2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttentionOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint units_count, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(!CNeuronBaseOCL::Init(numOutputs, myIndex, open_cl, units_count * window, optimization_type, batch))
      return false;
//---
   if(CheckPointer(Querys) == POINTER_INVALID)
     {
      Querys = new CNeuronConvOCL();
      if(CheckPointer(Querys) == POINTER_INVALID)
         return false;
      if(!Querys.Init(0, 0, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Querys.SetActivationFunction(None);
     }
//---
//if(CheckPointer(Keys)==POINTER_INVALID)
//  {
//   Keys=new CNeuronConvOCL();
//   if(CheckPointer(Keys)==POINTER_INVALID)
//      return false;
//   if(!Keys.Init(0,1,open_cl,window,window,window,units_count,optimization_type))
//      return false;
//   Keys.SetActivationFunction(None);
//  }
//---
   if(CheckPointer(Values) == POINTER_INVALID)
     {
      Values = new CNeuronConvOCL();
      if(CheckPointer(Values) == POINTER_INVALID)
         return false;
      if(!Values.Init(0, 2, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Values.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Scores) == POINTER_INVALID)
     {
      Scores = new CBufferFloat();
      if(CheckPointer(Scores) == POINTER_INVALID)
         return false;
     }
   if(!Scores.BufferInit(units_count * units_count, 0.0))
      return false;
   if(!Scores.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(AttentionOut) == POINTER_INVALID)
     {
      AttentionOut = new CNeuronBaseOCL();
      if(CheckPointer(AttentionOut) == POINTER_INVALID)
         return false;
      if(!AttentionOut.Init(0, 3, open_cl, window * units_count, optimization_type, batch))
         return false;
      AttentionOut.SetActivationFunction(None);
     }
//---
   if(CheckPointer(FF1) == POINTER_INVALID)
     {
      FF1 = new CNeuronConvOCL();
      if(CheckPointer(FF1) == POINTER_INVALID)
         return false;
      if(!FF1.Init(0, 4, open_cl, window, window, window * 4, units_count, optimization_type, batch))
         return false;
      FF1.SetActivationFunction(LReLU);
     }
//---
   if(CheckPointer(FF2) == POINTER_INVALID)
     {
      FF2 = new CNeuronConvOCL();
      if(CheckPointer(FF2) == POINTER_INVALID)
         return false;
      if(!FF2.Init(0, 5, open_cl, window * 4, window * 4, window, units_count, optimization_type, batch))
         return false;
      FF2.SetActivationFunction(None);
      FF2.SetGradientIndex(Gradient.GetIndex());
     }
//---
   iWindow = window;
   iUnits = units_count;
   activation = (ENUM_ACTIVATION)FF2.Activation();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttentionOCL::feedForward(CNeuronBaseOCL *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = 1;
      OpenCL.SetArgumentBuffer(def_k_Normilize, def_k_norm_buffer, prevLayer.getOutputIndex());
      OpenCL.SetArgument(def_k_Normilize, def_k_norm_dimension, prevLayer.Neurons());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_Normilize, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Normalize: %d", GetLastError());
         return false;
        }
      if(!prevLayer.Output.BufferRead())
         return false;
     }
//---
   if(CheckPointer(Querys) == POINTER_INVALID || !Querys.FeedForward(prevLayer))
      return false;
//if(CheckPointer(Keys)==POINTER_INVALID || !Keys.FeedForward(prevLayer))
//   return false;
   if(CheckPointer(Values) == POINTER_INVALID || !Values.FeedForward(prevLayer))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_querys, Querys.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_score, Scores.GetIndex());
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_dimension, iWindow);
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_mask, 0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionScore, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionScore: %d", GetLastError());
         return false;
        }
      if(!Scores.BufferRead())
         return false;
     }
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_scores, Scores.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_inputs, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_values, Values.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_out, AttentionOut.getOutputIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionOut, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Attention Out: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionOut.getOutputVal(temp))
         return false;
     }
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = 1;
      OpenCL.SetArgumentBuffer(def_k_Normilize, def_k_norm_buffer, AttentionOut.getOutputIndex());
      OpenCL.SetArgument(def_k_Normilize, def_k_norm_dimension, AttentionOut.Neurons());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_Normilize, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Normalize: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionOut.getOutputVal(temp))
         return false;
     }
//---
   if(!FF1.FeedForward(AttentionOut))
      return false;
   if(!FF2.FeedForward(FF1))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, AttentionOut.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, FF2.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, Output.GetIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      if(!Output.BufferRead())
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttentionOCL::calcInputGradients(CNeuronBaseOCL *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
   if(!FF2.calcInputGradients(FF1))
      return false;
   if(!FF1.calcInputGradients(AttentionOut))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, AttentionOut.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, Gradient.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, AttentionOut.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(AttentionOut.getGradient(temp) <= 0)
         return false;
     }
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_gradient, AttentionOut.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_keys_g, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_querys, Querys.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_querys_g, Querys.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_values, Values.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_values_g, Values.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_scores, Scores.GetIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionGradients, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionGradients: %d", GetLastError());
         return false;
        }
      float temp[];
      if(Querys.getGradient(temp) <= 0)
         return false;
     }
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, AttentionOut.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, AttentionOut.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 1.0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(AttentionOut.getGradient(temp) <= 0)
         return false;
     }
//---
   if(!Querys.calcInputGradients(prevLayer))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, AttentionOut.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, AttentionOut.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 1.0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(AttentionOut.getGradient(temp) <= 0)
         return false;
     }
//---
//   if(!Keys.calcInputGradients(prevLayer))
//      return false;
//---
//  {
//   uint global_work_offset[1]={0};
//   uint global_work_size[1];
//   global_work_size[0]=iUnits;
//   OpenCL.SetArgumentBuffer(def_k_MatrixSum,def_k_sum_matrix1,AttentionOut.getGradientIndex());
//   OpenCL.SetArgumentBuffer(def_k_MatrixSum,def_k_sum_matrix2,prevLayer.getGradientIndex());
//   OpenCL.SetArgumentBuffer(def_k_MatrixSum,def_k_sum_matrix_out,AttentionOut.getGradientIndex());
//   OpenCL.SetArgument(def_k_MatrixSum,def_k_sum_dimension,iWindow);
//   OpenCL.SetArgument(def_k_MatrixSum,def_k_sum_multiplyer,1.0);
//   if(!OpenCL.Execute(def_k_MatrixSum,1,global_work_offset,global_work_size))
//     {
//      printf("Error of execution kernel MatrixSum: %d",GetLastError());
//      return false;
//     }
//   float temp[];
//   if(AttentionOut.getGradient(temp)<=0)
//      return false;
//  }
//---
   if(!Values.calcInputGradients(prevLayer))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, AttentionOut.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, prevLayer.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow + 1);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.1);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(prevLayer.getGradient(temp) <= 0)
         return false;
     }
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = 1;
      OpenCL.SetArgumentBuffer(def_k_Normilize, def_k_norm_buffer, prevLayer.getGradientIndex());
      OpenCL.SetArgument(def_k_Normilize, def_k_norm_dimension, prevLayer.Neurons());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_Normilize, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Normalize: %d", GetLastError());
         return false;
        }
      float temp[];
      if(prevLayer.getGradient(temp) <= 0)
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttentionOCL::updateInputWeights(CNeuronBaseOCL *prevLayer)
  {
   if(!Querys.UpdateInputWeights(prevLayer))
      return false;
//if(!Keys.UpdateInputWeights(prevLayer))
//   return false;
   if(!Values.UpdateInputWeights(prevLayer))
      return false;
   if(!FF1.UpdateInputWeights(AttentionOut))
      return false;
   if(!FF2.UpdateInputWeights(FF1))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBufferFloat::BufferToCSV(const string file_name)
  {
   BufferRead();
   int h = FileOpen(file_name, FILE_CSV | FILE_WRITE);
   if(h == INVALID_HANDLE)
      return;
//---
   for(int i = 0; i < m_data_total; i++)
      FileWrite(h, m_data[i]);
   FileFlush(h);
   FileClose(h);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttentionOCL::Save(const int file_handle)
  {
   if(!CNeuronBaseOCL::Save(file_handle))
      return false;
   if(CheckPointer(Querys) == POINTER_INVALID || !Querys.Save(file_handle))
      return false;
//if(CheckPointer(Keys)==POINTER_INVALID || !Keys.Save(file_handle))
//   return false;
   if(CheckPointer(Values) == POINTER_INVALID || !Values.Save(file_handle))
      return false;
   if(CheckPointer(Scores) == POINTER_INVALID || !Scores.Save(file_handle))
      return false;
   if(CheckPointer(AttentionOut) == POINTER_INVALID || !AttentionOut.Save(file_handle))
      return false;
   if(CheckPointer(FF1) == POINTER_INVALID || !FF1.Save(file_handle))
      return false;
   if(CheckPointer(FF2) == POINTER_INVALID || !FF2.Save(file_handle))
      return false;
   if(FileWriteInteger(file_handle, iWindow, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, iUnits, INT_VALUE) < INT_VALUE)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttentionOCL::Load(const int file_handle)
  {
   if(!CNeuronBaseOCL::Load(file_handle))
      return false;
//---
   if(CheckPointer(Querys) == POINTER_INVALID)
      Querys = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Querys.Load(file_handle))
      return false;
//---
//if(CheckPointer(Keys)==POINTER_INVALID)
//   Keys=new CNeuronConvOCL();
//if(FileReadInteger(file_handle,INT_VALUE)!=defNeuronConvOCL || !Keys.Load(file_handle))
//   return false;
//---
   if(CheckPointer(Values) == POINTER_INVALID)
      Values = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Values.Load(file_handle))
      return false;
//---
   if(CheckPointer(Scores) == POINTER_INVALID)
      Scores = new CBufferFloat();
   if(Scores.GetIndex() >= 0)
      Scores.BufferFree();
   if(!Scores.Load(file_handle))
      return false;
   if(!Scores.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(AttentionOut) == POINTER_INVALID)
      AttentionOut = new CNeuronBaseOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronBaseOCL || !AttentionOut.Load(file_handle))
      return false;
//---
   if(CheckPointer(FF1) == POINTER_INVALID)
      FF1 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !FF1.Load(file_handle))
      return false;
   if(CheckPointer(FF2) == POINTER_INVALID)
      FF2 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !FF2.Load(file_handle))
      return false;
   iWindow = FileReadInteger(file_handle);
   iUnits = FileReadInteger(file_handle);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription*  CNeuronAttentionOCL::GetLayerInfo()
  {
   CLayerDescription* result = CNeuronBaseOCL::GetLayerInfo();
   if(!result)
      return result;
   result.window = (int)iWindow;
   result.count = (int)iUnits;
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConvOCL::Load(const int file_handle)
  {
   if(!CNeuronProofOCL::Load(file_handle))
      return false;
//---
   if(CheckPointer(WeightsConv) == POINTER_INVALID)
      WeightsConv = new CBufferFloat();
   if(WeightsConv.GetIndex() >= 0)
      WeightsConv.BufferFree();
   if(!WeightsConv.Load(file_handle))
      return false;
   if(!WeightsConv.BufferCreate(OpenCL))
      return false;
//---
   if(optimization == SGD)
     {
      if(CheckPointer(DeltaWeightsConv) == POINTER_INVALID)
         DeltaWeightsConv = new CBufferFloat();
      if(DeltaWeightsConv.GetIndex() >= 0)
         DeltaWeightsConv.BufferFree();
      if(!DeltaWeightsConv.Load(file_handle))
         return false;
      if(!DeltaWeightsConv.BufferCreate(OpenCL))
         return false;
     }
   else
     {
      if(CheckPointer(FirstMomentumConv) == POINTER_INVALID)
         FirstMomentumConv = new CBufferFloat();
      if(FirstMomentumConv.GetIndex() >= 0)
         FirstMomentumConv.BufferFree();
      if(!FirstMomentumConv.Load(file_handle))
         return false;
      if(!FirstMomentumConv.BufferCreate(OpenCL))
         return false;
      //---
      if(CheckPointer(SecondMomentumConv) == POINTER_INVALID)
         SecondMomentumConv = new CBufferFloat();
      if(SecondMomentumConv.GetIndex() >= 0)
         SecondMomentumConv.BufferFree();
      if(!SecondMomentumConv.Load(file_handle))
         return false;
      if(!SecondMomentumConv.BufferCreate(OpenCL))
         return false;
     }
   iWindowOut = FileReadInteger(file_handle);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConvOCL::Save(const int file_handle)
  {
   if(!CNeuronProofOCL::Save(file_handle))
      return false;
//---
   if(CheckPointer(WeightsConv) == POINTER_INVALID || !WeightsConv.Save(file_handle))
      return false;
   if(optimization == SGD && (CheckPointer(DeltaWeightsConv) == POINTER_INVALID || !DeltaWeightsConv.BufferRead() || !DeltaWeightsConv.Save(file_handle)))
      return false;
   if(optimization != SGD && (CheckPointer(FirstMomentumConv) == POINTER_INVALID || !FirstMomentumConv.BufferRead() || !FirstMomentumConv.Save(file_handle)))
      return false;
   if(optimization != SGD && (CheckPointer(SecondMomentumConv) == POINTER_INVALID || !SecondMomentumConv.BufferRead() || !SecondMomentumConv.Save(file_handle)))
      return false;
   if(FileWriteInteger(file_handle, iWindowOut, INT_VALUE) < INT_VALUE)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProofOCL::Save(const int file_handle)
  {
   if(!CNeuronBaseOCL::Save(file_handle))
      return false;
   if(FileWriteInteger(file_handle, iWindow, INT_VALUE) < INT_VALUE)
      return false;
   if(FileWriteInteger(file_handle, iStep, INT_VALUE) < INT_VALUE)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronProofOCL::Load(const int file_handle)
  {
   if(!CNeuronBaseOCL::Load(file_handle))
      return false;
   iWindow = FileReadInteger(file_handle);
   iStep = FileReadInteger(file_handle);
//---
   return true;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_base
///\class CNeuronMHAttentionOCL
///\brief Class of Multi-Head Self-Attention layer GPU calculation
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/8909#para52">the link.</A>
//+------------------------------------------------------------------+
class CNeuronMHAttentionOCL   :  public CNeuronAttentionOCL
  {
protected:
   CNeuronConvOCL    *Querys2;            ///< Convolution layer for Querys Head 2
   CNeuronConvOCL    *Querys3;            ///< Convolution layer for Querys Head 3
   CNeuronConvOCL    *Querys4;            ///< Convolution layer for Querys Head 4
   CNeuronConvOCL    *Keys2;              ///< Convolution layer for Keys Head 2
   CNeuronConvOCL    *Keys3;              ///< Convolution layer for Keys Head 3
   CNeuronConvOCL    *Keys4;              ///< Convolution layer for Keys Head 4
   CNeuronConvOCL    *Values2;            ///< Convolution layer for Values Head 2
   CNeuronConvOCL    *Values3;            ///< Convolution layer for Values Head 3
   CNeuronConvOCL    *Values4;            ///< Convolution layer for Values Head 4
   CBufferFloat      *Scores2;            ///< Buffer for Scores matrix Head 2
   CBufferFloat      *Scores3;            ///< Buffer for Scores matrix Head 3
   CBufferFloat      *Scores4;            ///< Buffer for Scores matrix Head 4
   CNeuronBaseOCL    *AttentionOut2;      ///< Layer of Self-Attention Out
   CNeuronBaseOCL    *AttentionOut3;      ///< Layer of Self-Attention Out
   CNeuronBaseOCL    *AttentionOut4;      ///< Layer of Self-Attention Out
   CNeuronBaseOCL    *AttentionConcatenate;///< Layer of Concatenate Self-Attention Out
   CNeuronConvOCL    *Weights0;           ///< Convolution layer for Weights0
   //---
   virtual bool      feedForward(CNeuronBaseOCL *prevLayer);                  ///< Feed Forward method.@param prevLayer Pointer to previos layer.
   virtual bool      updateInputWeights(CNeuronBaseOCL *prevLayer);            ///< Method for updating weights.@param prevLayer Pointer to previos layer.
   /// Method to transfer gradients inside Head Self-Attention
   virtual bool      calcHeadGradient(CNeuronConvOCL *query, CNeuronConvOCL *value, CBufferFloat *score, CNeuronBaseOCL *attention, CNeuronBaseOCL *prevLayer);

public:
   /** Constructor */
                     CNeuronMHAttentionOCL(void) {};
   /** Destructor */~CNeuronMHAttentionOCL(void);
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint units_count, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object.@param[in] window Size of in/out window and step.@param[in] units_countNumber of neurons.@param[in] optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   virtual bool      calcInputGradients(CNeuronBaseOCL *prevLayer);  ///< Method to transfer gradients to previous layer @param[in] prevLayer Pointer to previous layer.
   //---
   virtual int       Type(void)   const   {  return defNeuronMHAttentionOCL;   }///< Identificator of class.@return Type of class
   //--- methods for working with files
   virtual bool      Save(int const file_handle);   ///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);   ///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronMHAttentionOCL::~CNeuronMHAttentionOCL(void)
  {
   if(CheckPointer(Querys2) != POINTER_INVALID)
      delete Querys2;
   if(CheckPointer(Querys3) != POINTER_INVALID)
      delete Querys3;
   if(CheckPointer(Querys4) != POINTER_INVALID)
      delete Querys4;
   if(CheckPointer(Keys2) != POINTER_INVALID)
      delete Keys2;
   if(CheckPointer(Keys3) != POINTER_INVALID)
      delete Keys3;
   if(CheckPointer(Keys4) != POINTER_INVALID)
      delete Keys4;
   if(CheckPointer(Values2) != POINTER_INVALID)
      delete Values2;
   if(CheckPointer(Values3) != POINTER_INVALID)
      delete Values3;
   if(CheckPointer(Values4) != POINTER_INVALID)
      delete Values4;
   if(CheckPointer(Scores2) != POINTER_INVALID)
      delete Scores2;
   if(CheckPointer(Scores3) != POINTER_INVALID)
      delete Scores3;
   if(CheckPointer(Scores4) != POINTER_INVALID)
      delete Scores4;
   if(CheckPointer(Weights0) != POINTER_INVALID)
      delete Weights0;
   if(CheckPointer(AttentionOut2) != POINTER_INVALID)
      delete AttentionOut2;
   if(CheckPointer(AttentionOut3) != POINTER_INVALID)
      delete AttentionOut3;
   if(CheckPointer(AttentionOut4) != POINTER_INVALID)
      delete AttentionOut4;
   if(CheckPointer(AttentionConcatenate) != POINTER_INVALID)
      delete AttentionConcatenate;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint units_count, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(!CNeuronAttentionOCL::Init(numOutputs, myIndex, open_cl, window, units_count, optimization_type, batch))
      return false;
//---
   if(CheckPointer(Querys2) == POINTER_INVALID)
     {
      Querys2 = new CNeuronConvOCL();
      if(CheckPointer(Querys2) == POINTER_INVALID)
         return false;
      if(!Querys2.Init(0, 6, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Querys2.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Querys3) == POINTER_INVALID)
     {
      Querys3 = new CNeuronConvOCL();
      if(CheckPointer(Querys3) == POINTER_INVALID)
         return false;
      if(!Querys3.Init(0, 7, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Querys3.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Querys4) == POINTER_INVALID)
     {
      Querys4 = new CNeuronConvOCL();
      if(CheckPointer(Querys4) == POINTER_INVALID)
         return false;
      if(!Querys4.Init(0, 8, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Querys4.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Values2) == POINTER_INVALID)
     {
      Values2 = new CNeuronConvOCL();
      if(CheckPointer(Values2) == POINTER_INVALID)
         return false;
      if(!Values2.Init(0, 9, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Values2.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Values3) == POINTER_INVALID)
     {
      Values3 = new CNeuronConvOCL();
      if(CheckPointer(Values3) == POINTER_INVALID)
         return false;
      if(!Values3.Init(0, 10, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Values3.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Values4) == POINTER_INVALID)
     {
      Values4 = new CNeuronConvOCL();
      if(CheckPointer(Values4) == POINTER_INVALID)
         return false;
      if(!Values4.Init(0, 11, open_cl, window, window, window, units_count, optimization_type, batch))
         return false;
      Values4.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Scores2) == POINTER_INVALID)
     {
      Scores2 = new CBufferFloat();
      if(CheckPointer(Scores2) == POINTER_INVALID)
         return false;
     }
   if(!Scores2.BufferInit(units_count * units_count, 0.0))
      return false;
   if(!Scores2.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(Scores3) == POINTER_INVALID)
     {
      Scores3 = new CBufferFloat();
      if(CheckPointer(Scores3) == POINTER_INVALID)
         return false;
     }
   if(!Scores3.BufferInit(units_count * units_count, 0.0))
      return false;
   if(!Scores3.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(Scores4) == POINTER_INVALID)
     {
      Scores4 = new CBufferFloat();
      if(CheckPointer(Scores4) == POINTER_INVALID)
         return false;
     }
   if(!Scores4.BufferInit(units_count * units_count, 0.0))
      return false;
   if(!Scores4.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(AttentionOut2) == POINTER_INVALID)
     {
      AttentionOut2 = new CNeuronBaseOCL();
      if(CheckPointer(AttentionOut2) == POINTER_INVALID)
         return false;
      if(!AttentionOut2.Init(0, 12, open_cl, window * units_count, optimization_type, batch))
         return false;
      AttentionOut2.SetActivationFunction(None);
     }
//---
   if(CheckPointer(AttentionOut3) == POINTER_INVALID)
     {
      AttentionOut3 = new CNeuronBaseOCL();
      if(CheckPointer(AttentionOut3) == POINTER_INVALID)
         return false;
      if(!AttentionOut3.Init(0, 13, open_cl, window * units_count, optimization_type, batch))
         return false;
      AttentionOut3.SetActivationFunction(None);
     }
//---
   if(CheckPointer(AttentionOut4) == POINTER_INVALID)
     {
      AttentionOut4 = new CNeuronBaseOCL();
      if(CheckPointer(AttentionOut4) == POINTER_INVALID)
         return false;
      if(!AttentionOut4.Init(0, 14, open_cl, window * units_count, optimization_type, batch))
         return false;
      AttentionOut4.SetActivationFunction(None);
     }
//---
   if(CheckPointer(AttentionConcatenate) == POINTER_INVALID)
     {
      AttentionConcatenate = new CNeuronBaseOCL();
      if(CheckPointer(AttentionConcatenate) == POINTER_INVALID)
         return false;
      if(!AttentionConcatenate.Init(0, 15, open_cl, 4 * window * units_count, optimization_type, batch))
         return false;
      AttentionConcatenate.SetActivationFunction(None);
     }
//---
   if(CheckPointer(Weights0) == POINTER_INVALID)
     {
      Weights0 = new CNeuronConvOCL();
      if(CheckPointer(Weights0) == POINTER_INVALID)
         return false;
      if(!Weights0.Init(0, 16, open_cl, 4 * window, 4 * window, window, units_count, optimization_type, batch))
         return false;
      Weights0.SetActivationFunction(None);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::feedForward(CNeuronBaseOCL *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = 1;
      OpenCL.SetArgumentBuffer(def_k_Normilize, def_k_norm_buffer, prevLayer.getOutputIndex());
      OpenCL.SetArgument(def_k_Normilize, def_k_norm_dimension, prevLayer.Neurons());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_Normilize, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Normalize: %d", GetLastError());
         return false;
        }
      if(!prevLayer.Output.BufferRead())
         return false;
     }
//---
   if(CheckPointer(Querys) == POINTER_INVALID || !Querys.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Querys2) == POINTER_INVALID || !Querys2.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Querys3) == POINTER_INVALID || !Querys3.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Querys4) == POINTER_INVALID || !Querys4.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Values) == POINTER_INVALID || !Values.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Values2) == POINTER_INVALID || !Values2.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Values3) == POINTER_INVALID || !Values3.FeedForward(prevLayer))
      return false;
   if(CheckPointer(Values4) == POINTER_INVALID || !Values4.FeedForward(prevLayer))
      return false;
//--- Scores Head 1
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_querys, Querys.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_score, Scores.GetIndex());
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_dimension, iWindow);
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_mask, 0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionScore, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionScore: %d", GetLastError());
         return false;
        }
      if(!Scores.BufferRead())
         return false;
     }
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_scores, Scores.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_inputs, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_values, Values.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_out, AttentionOut.getOutputIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionOut, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Attention Out: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionOut.getOutputVal(temp))
         return false;
     }
//--- Scores Head 2
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_querys, Querys2.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_score, Scores2.GetIndex());
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_dimension, iWindow);
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_mask, 0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionScore, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionScore: %d", GetLastError());
         return false;
        }
      if(!Scores2.BufferRead())
         return false;
     }
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_scores, Scores2.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_inputs, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_values, Values2.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_out, AttentionOut2.getOutputIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionOut, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Attention Out: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionOut2.getOutputVal(temp))
         return false;
     }
//--- Scores Head 3
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_querys, Querys3.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_score, Scores3.GetIndex());
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_dimension, iWindow);
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_mask, 0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionScore, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionScore: %d", GetLastError());
         return false;
        }
      if(!Scores3.BufferRead())
         return false;
     }
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_scores, Scores3.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_inputs, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_values, Values3.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_out, AttentionOut3.getOutputIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionOut, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Attention Out: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionOut3.getOutputVal(temp))
         return false;
     }
//--- Scores Head 4
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_querys, Querys4.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionScore, def_k_as_score, Scores4.GetIndex());
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_dimension, iWindow);
      OpenCL.SetArgument(def_k_AttentionScore, def_k_as_mask, 0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionScore, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionScore: %d", GetLastError());
         return false;
        }
      if(!Scores4.BufferRead())
         return false;
     }
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_scores, Scores4.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_inputs, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_values, Values4.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionOut, def_k_aout_out, AttentionOut4.getOutputIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionOut, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Attention Out: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionOut4.getOutputVal(temp))
         return false;
     }
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_ConcatenateMatrix, def_k_conc_input1, AttentionOut.getOutputIndex());
      OpenCL.SetArgument(def_k_ConcatenateMatrix, def_k_conc_window1, iWindow);
      OpenCL.SetArgumentBuffer(def_k_ConcatenateMatrix, def_k_conc_input2, AttentionOut2.getOutputIndex());
      OpenCL.SetArgument(def_k_ConcatenateMatrix, def_k_conc_window2, iWindow);
      OpenCL.SetArgumentBuffer(def_k_ConcatenateMatrix, def_k_conc_input3, AttentionOut3.getOutputIndex());
      OpenCL.SetArgument(def_k_ConcatenateMatrix, def_k_conc_window3, iWindow);
      OpenCL.SetArgumentBuffer(def_k_ConcatenateMatrix, def_k_conc_input4, AttentionOut4.getOutputIndex());
      OpenCL.SetArgument(def_k_ConcatenateMatrix, def_k_conc_window4, iWindow);
      OpenCL.SetArgumentBuffer(def_k_ConcatenateMatrix, def_k_conc_out, AttentionConcatenate.getOutputIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_ConcatenateMatrix, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Concatenate Matrix: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!AttentionConcatenate.getOutputVal(temp))
         return false;
     }
//---
   if(CheckPointer(Weights0) == POINTER_INVALID || !Weights0.FeedForward(AttentionConcatenate))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, Weights0.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, Weights0.getOutputIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      if(!Output.BufferRead())
         return false;
     }
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = 1;
      OpenCL.SetArgumentBuffer(def_k_Normilize, def_k_norm_buffer, Weights0.getOutputIndex());
      OpenCL.SetArgument(def_k_Normilize, def_k_norm_dimension, Weights0.Neurons());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_Normilize, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Normalize: %d", GetLastError());
         return false;
        }
      float temp[];
      if(!Weights0.getOutputVal(temp))
         return false;
     }
//---
   if(!FF1.FeedForward(Weights0))
      return false;
   if(!FF2.FeedForward(FF1))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, Weights0.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, FF2.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, Output.GetIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      if(!Output.BufferRead())
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::calcInputGradients(CNeuronBaseOCL *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
   if(!FF2.calcInputGradients(FF1))
      return false;
   if(!FF1.calcInputGradients(Weights0))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, Weights0.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, Gradient.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, Weights0.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(Weights0.getGradient(temp) <= 0)
         return false;
     }
//---
   if(!Weights0.calcInputGradients(AttentionConcatenate))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_DeconcatenateMatrix, def_k_dconc_output1, AttentionOut.getGradientIndex());
      OpenCL.SetArgument(def_k_DeconcatenateMatrix, def_k_dconc_window1, iWindow);
      OpenCL.SetArgumentBuffer(def_k_DeconcatenateMatrix, def_k_dconc_output2, AttentionOut2.getGradientIndex());
      OpenCL.SetArgument(def_k_DeconcatenateMatrix, def_k_dconc_window2, iWindow);
      OpenCL.SetArgumentBuffer(def_k_DeconcatenateMatrix, def_k_dconc_output3, AttentionOut3.getGradientIndex());
      OpenCL.SetArgument(def_k_DeconcatenateMatrix, def_k_dconc_window3, iWindow);
      OpenCL.SetArgumentBuffer(def_k_DeconcatenateMatrix, def_k_dconc_output4, AttentionOut4.getGradientIndex());
      OpenCL.SetArgument(def_k_DeconcatenateMatrix, def_k_dconc_window4, iWindow);
      OpenCL.SetArgumentBuffer(def_k_DeconcatenateMatrix, def_k_dconc_inputs, AttentionConcatenate.getGradientIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_DeconcatenateMatrix, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Deconcantenate Matrix: %d", GetLastError());
         return false;
        }
      float temp[];
      if(AttentionConcatenate.getGradient(temp) <= 0)
         return false;
     }
//---
   if(!calcHeadGradient(Querys, Values, Scores, AttentionOut, prevLayer))
      return false;
   if(!calcHeadGradient(Querys2, Values2, Scores2, AttentionOut2, prevLayer))
      return false;
   if(!calcHeadGradient(Querys3, Values3, Scores3, AttentionOut3, prevLayer))
      return false;
   if(!calcHeadGradient(Querys4, Values4, Scores4, AttentionOut4, prevLayer))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_Matrix5Sum, def_k_sum5_matrix1, AttentionOut.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_Matrix5Sum, def_k_sum5_matrix2, AttentionOut2.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_Matrix5Sum, def_k_sum5_matrix3, AttentionOut3.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_Matrix5Sum, def_k_sum5_matrix4, AttentionOut4.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_Matrix5Sum, def_k_sum5_matrix5, Weights0.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_Matrix5Sum, def_k_sum5_matrix_out, prevLayer.getGradientIndex());
      OpenCL.SetArgument(def_k_Matrix5Sum, def_k_sum5_dimension, iWindow);
      OpenCL.SetArgument(def_k_Matrix5Sum, def_k_sum5_multiplyer, 0.2);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_Matrix5Sum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel Matrix5Sum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(prevLayer.getGradient(temp) <= 0)
         return false;
     }
//---
     {
      //uint global_work_offset[1]={0};
      //uint global_work_size[1];
      //global_work_size[0]=1;
      //OpenCL.SetArgumentBuffer(def_k_Normilize,def_k_norm_buffer,prevLayer.getGradientIndex());
      //OpenCL.SetArgument(def_k_Normilize,def_k_norm_dimension,prevLayer.Neurons());
      //if(!OpenCL.Execute(def_k_Normilize,1,global_work_offset,global_work_size))
      //  {
      //   printf("Error of execution kernel Normalize: %d",GetLastError());
      //   return false;
      //  }
      //float temp[];
      //if(prevLayer.getGradient(temp)<=0)
      //   return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::calcHeadGradient(CNeuronConvOCL *query, CNeuronConvOCL *value, CBufferFloat *score, CNeuronBaseOCL *attention, CNeuronBaseOCL *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
     {
      uint global_work_offset[2] = {0, 0};
      uint global_work_size[2];
      global_work_size[0] = iUnits;
      global_work_size[1] = iWindow;
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_gradient, attention.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_keys, prevLayer.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_keys_g, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_querys, query.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_querys_g, query.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_values, value.getOutputIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_values_g, value.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_AttentionGradients, def_k_ag_scores, score.GetIndex());
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_AttentionGradients, 2, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel AttentionGradients: %d", GetLastError());
         return false;
        }
      float temp[];
      if(query.getGradient(temp) <= 0)
         return false;
     }
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, attention.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(attention.getGradient(temp) <= 0)
         return false;
     }
//---
   if(!query.calcInputGradients(prevLayer))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, attention.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, attention.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 1.0);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(attention.getGradient(temp) <= 0)
         return false;
     }
//---
   if(!value.calcInputGradients(prevLayer))
      return false;
//---
     {
      uint global_work_offset[1] = {0};
      uint global_work_size[1];
      global_work_size[0] = iUnits;
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, attention.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, prevLayer.getGradientIndex());
      OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, attention.getGradientIndex());
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow + 1);
      OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.33);
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel MatrixSum: %d", GetLastError());
         return false;
        }
      float temp[];
      if(prevLayer.getGradient(temp) <= 0)
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::updateInputWeights(CNeuronBaseOCL *prevLayer)
  {
   if(!Querys.UpdateInputWeights(prevLayer) || !Querys2.UpdateInputWeights(prevLayer) ||
      !Querys3.UpdateInputWeights(prevLayer) || !Querys4.UpdateInputWeights(prevLayer))
      return false;
//---
   if(!Values.UpdateInputWeights(prevLayer) || !Values2.UpdateInputWeights(prevLayer) ||
      !Values3.UpdateInputWeights(prevLayer) || !Values4.UpdateInputWeights(prevLayer))
      return false;
   if(!Weights0.UpdateInputWeights(AttentionConcatenate))
      return false;
   if(!FF1.UpdateInputWeights(Weights0))
      return false;
   if(!FF2.UpdateInputWeights(FF1))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::Save(const int file_handle)
  {
   if(!CNeuronAttentionOCL::Save(file_handle))
      return false;
//---
   if(CheckPointer(Querys2) == POINTER_INVALID || !Querys2.Save(file_handle))
      return false;
   if(CheckPointer(Values2) == POINTER_INVALID || !Values2.Save(file_handle))
      return false;
   if(CheckPointer(Scores2) == POINTER_INVALID || !Scores2.Save(file_handle))
      return false;
   if(CheckPointer(AttentionOut2) == POINTER_INVALID || !AttentionOut2.Save(file_handle))
      return false;
//---
   if(CheckPointer(Querys3) == POINTER_INVALID || !Querys3.Save(file_handle))
      return false;
   if(CheckPointer(Values3) == POINTER_INVALID || !Values3.Save(file_handle))
      return false;
   if(CheckPointer(Scores3) == POINTER_INVALID || !Scores3.Save(file_handle))
      return false;
   if(CheckPointer(AttentionOut3) == POINTER_INVALID || !AttentionOut3.Save(file_handle))
      return false;
//---
   if(CheckPointer(Querys4) == POINTER_INVALID || !Querys4.Save(file_handle))
      return false;
   if(CheckPointer(Values4) == POINTER_INVALID || !Values4.Save(file_handle))
      return false;
   if(CheckPointer(Scores4) == POINTER_INVALID || !Scores4.Save(file_handle))
      return false;
   if(CheckPointer(AttentionOut4) == POINTER_INVALID || !AttentionOut4.Save(file_handle))
      return false;
//---
   if(CheckPointer(AttentionConcatenate) == POINTER_INVALID || !AttentionConcatenate.Save(file_handle))
      return false;
   if(CheckPointer(Weights0) == POINTER_INVALID || !Weights0.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMHAttentionOCL::Load(const int file_handle)
  {
   if(!CNeuronAttentionOCL::Load(file_handle))
      return false;
//---
   if(CheckPointer(Querys2) == POINTER_INVALID)
      Querys2 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Querys2.Load(file_handle))
      return false;
//---
   if(CheckPointer(Values2) == POINTER_INVALID)
      Values2 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Values2.Load(file_handle))
      return false;
//---
   if(CheckPointer(Scores2) == POINTER_INVALID)
      Scores2 = new CBufferFloat();
   if(Scores2.GetIndex() >= 0)
      Scores2.BufferFree();
   if(!Scores2.Load(file_handle))
      return false;
   if(!Scores2.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(AttentionOut2) == POINTER_INVALID)
      AttentionOut2 = new CNeuronBaseOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronBaseOCL || !AttentionOut2.Load(file_handle))
      return false;
//---
   if(CheckPointer(Querys3) == POINTER_INVALID)
      Querys3 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Querys3.Load(file_handle))
      return false;
//---
   if(CheckPointer(Values3) == POINTER_INVALID)
      Values3 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Values3.Load(file_handle))
      return false;
//---
   if(CheckPointer(Scores3) == POINTER_INVALID)
      Scores3 = new CBufferFloat();
   if(Scores3.GetIndex() >= 0)
      Scores3.BufferFree();
   if(!Scores3.Load(file_handle))
      return false;
   if(!Scores3.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(AttentionOut3) == POINTER_INVALID)
      AttentionOut3 = new CNeuronBaseOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronBaseOCL || !AttentionOut3.Load(file_handle))
      return false;
//---
   if(CheckPointer(Querys4) == POINTER_INVALID)
      Querys4 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Querys4.Load(file_handle))
      return false;
//---
   if(CheckPointer(Values4) == POINTER_INVALID)
      Values4 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Values4.Load(file_handle))
      return false;
//---
   if(CheckPointer(Scores4) == POINTER_INVALID)
      Scores4 = new CBufferFloat();
   if(Scores4.GetIndex() >= 0)
      Scores4.BufferFree();
   if(!Scores4.Load(file_handle))
      return false;
   if(!Scores4.BufferCreate(OpenCL))
      return false;
//---
   if(CheckPointer(AttentionOut4) == POINTER_INVALID)
      AttentionOut4 = new CNeuronBaseOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronBaseOCL || !AttentionOut4.Load(file_handle))
      return false;
//---
   if(CheckPointer(AttentionConcatenate) == POINTER_INVALID)
      AttentionConcatenate = new CNeuronBaseOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronBaseOCL || !AttentionConcatenate.Load(file_handle))
      return false;
//---
   if(CheckPointer(Weights0) == POINTER_INVALID)
      Weights0 = new CNeuronConvOCL();
   if(FileReadInteger(file_handle, INT_VALUE) != defNeuronConvOCL || !Weights0.Load(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronMHAttentionOCL::GetLayerInfo(void)
  {
   CLayerDescription* result = CNeuronAttentionOCL::GetLayerInfo();
   if(!result)
      return result;
   result.step = 4;
//---
   return result;
  }
//+------------------------------------------------------------------+
///\class CCollection
///\brief Class of objects collection.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9025#para41">the link.</A>
//+------------------------------------------------------------------+
class CCollection    :  public CArrayObj
  {
public:
                     CCollection(void) {};
                    ~CCollection(void) {};
   //---
   virtual bool      CreateElement(const int index)
     {
      if(index < 0)
         return false;
      //---
      if(index >= m_data_max)
        {
         if(!Reserve(index - m_data_total))
            return false;
        }
      m_data[index] = new CBufferFloat();
      return(CheckPointer(m_data[index]) != POINTER_INVALID);
     }
  };
//+------------------------------------------------------------------+
///\ingroup neuron_base
///\class CNeuronMLMHAttentionOCL
///\brief Class of Multilayer multi-headed attention neuron.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9025#para41">the link.</A>
//+------------------------------------------------------------------+
class CNeuronMLMHAttentionOCL       :  public CNeuronBaseOCL
  {
protected:
   uint              iLayers;                                     ///< Number of inner layers
   uint              iHeads;                                      ///< Number of heads
   uint              iWindow;                                     ///< Input window size
   uint              iUnits;                                      ///< Number of units
   uint              iWindowKey;                                  ///< Size of Key/Query window
   //---
   CCollection       *QKV_Tensors;                                ///< The collection of tensors of Queries, Keys and Values
   CCollection       *QKV_Weights;                                ///< The collection of Matrix of weights to previous layer
   CCollection       *S_Tensors;                                  ///< The collection of Scores tensors
   CCollection       *AO_Tensors;                                 ///< The collection of Attention Out tensors
   CCollection       *FF_Tensors;                                 ///< The collection of tensors of Feed Forward output
   CCollection       *FF_Weights;                                 ///< The collection of Matrix of Feed Forward weights

   ///\ingroup neuron_base_ff
   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL);               ///< \brief Feed Forward method of calling kernel ::FeedForward().@param NeuronOCL Pointer to previos layer.
   virtual bool      ConvolutionForward(CBufferFloat *weights, CBufferFloat *inputs, CBufferFloat *outputs, uint window, uint window_out, ENUM_ACTIVATION activ);
   ///< \brief Convolution Feed Forward method of calling kernel ::FeedForwardConv().
   virtual bool      AttentionScore(CBufferFloat *qkv, CBufferFloat *scores, bool mask = true);
   ///< \brief Multi-heads attention scores method of calling kernel ::MHAttentionScore().
   virtual bool      AttentionOut(CBufferFloat *qkv, CBufferFloat *scores, CBufferFloat *out);
   ///< \brief Multi-heads attention out method of calling kernel ::MHAttentionOut().
   virtual bool      SumAndNormilize(CBufferFloat *tensor1, CBufferFloat *tensor2, CBufferFloat *out);
   ///< \brief Method sum and normilize 2 tensors by calling 2 kernels ::SumMatrix() and ::Normalize().
   ///\ingroup neuron_base_opt
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL);        ///< Method for updating weights.\details Calling one of kernels ::UpdateWeightsMomentum() or ::UpdateWeightsAdam() in depends of optimization type (#ENUM_OPTIMIZATION).@param NeuronOCL Pointer to previos layer.
   virtual bool      ConvolutuionUpdateWeights(CBufferFloat *weights, CBufferFloat *gradient, CBufferFloat *inputs, CBufferFloat *momentum1, CBufferFloat *momentum2, uint window, uint window_out);
   ///< Method for updating weights in convolution layer.\details Calling one of kernels ::UpdateWeightsConvMomentum() or ::UpdateWeightsConvAdam() in depends of optimization type (#ENUM_OPTIMIZATION).
   virtual bool      ConvolutionInputGradients(CBufferFloat *weights, CBufferFloat *gradient, CBufferFloat *inputs, CBufferFloat *inp_gradient, uint window, uint window_out, uint activ);
   ///< Method of passing gradients through a convolutional layer.
   virtual bool      AttentionInsideGradients(CBufferFloat *qkv, CBufferFloat *qkv_g, CBufferFloat *scores, CBufferFloat *scores_g, CBufferFloat *gradient);
   ///< Method of passing gradients through attention layer.
public:
   /** Constructor */
                     CNeuronMLMHAttentionOCL(void);
   /** Destructor */~CNeuronMLMHAttentionOCL(void);
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint window_key, uint heads, uint units_count, uint layers, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object.@param[in] window Size of in/out window and step.@param[in] units_countNumber of neurons.@param[in] optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   virtual bool      calcInputGradients(CNeuronBaseOCL *prevLayer);  ///< Method to transfer gradients to previous layer @param[in] prevLayer Pointer to previous layer.
   //---
   virtual int       Type(void)   const   {  return defNeuronMLMHAttentionOCL;   }///< Identificator of class.@return Type of class
   //--- methods for working with files
   virtual bool      Save(int const file_handle);  ///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);  ///< Load method @param[in] file_handle handle of file @return logical result of operation
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronMLMHAttentionOCL::CNeuronMLMHAttentionOCL(void)   :  iLayers(0),
   iHeads(0),
   iWindow(0),
   iWindowKey(0),
   iUnits(0)
  {
   QKV_Tensors = new CCollection();
   QKV_Weights = new CCollection();
   S_Tensors = new CCollection();
   AO_Tensors = new CCollection();
   FF_Tensors = new CCollection();
   FF_Weights = new CCollection();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronMLMHAttentionOCL::~CNeuronMLMHAttentionOCL(void)
  {
   if(CheckPointer(QKV_Tensors) != POINTER_INVALID)
      delete QKV_Tensors;
   if(CheckPointer(QKV_Weights) != POINTER_INVALID)
      delete QKV_Weights;
   if(CheckPointer(S_Tensors) != POINTER_INVALID)
      delete S_Tensors;
   if(CheckPointer(AO_Tensors) != POINTER_INVALID)
      delete AO_Tensors;
   if(CheckPointer(FF_Tensors) != POINTER_INVALID)
      delete FF_Tensors;
   if(CheckPointer(FF_Weights) != POINTER_INVALID)
      delete FF_Weights;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint window, uint window_key, uint heads, uint units_count, uint layers, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(!CNeuronBaseOCL::Init(numOutputs, myIndex, open_cl, window * units_count, optimization_type, batch))
      return false;
//---
   iWindow = fmax(window, 1);
   iWindowKey = fmax(window_key, 1);
   iUnits = fmax(units_count, 1);
   iHeads = fmax(heads, 1);
   iLayers = fmax(layers, 1);
//---
   uint num = 3 * iWindowKey * iHeads * iUnits;       //Size of QKV tensor
   uint qkv_weights = 3 * (iWindow + 1) * iWindowKey * iHeads; //Size of weights' matrix of QKV tenzor
   uint scores = iUnits * iUnits * iHeads;            //Size of Score tensor
   uint mh_out = iWindowKey * iHeads * iUnits;        //Size of multi-heads self-attention
   uint out = iWindow * iUnits;                       //Size of our tensore
   uint w0 = (iWindowKey + 1) * iHeads * iWindow;     //Size W0 tensor
   uint ff_1 = 4 * (iWindow + 1) * iWindow;           //Size of weights' matrix 1-st feed forward layer
   uint ff_2 = (4 * iWindow + 1) * iWindow;           //Size of weights' matrix 2-nd feed forward layer
//---
   for(uint i = 0; i < iLayers; i++)
     {
      CBufferFloat *temp = NULL;
      for(int d = 0; d < 2; d++)
        {
         //--- Initilize QKV tensor
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(num, 0))
            return false;
         if(!QKV_Tensors.Add(temp))
            return false;
         //--- Initialize scores
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(scores, 0))
            return false;
         if(!S_Tensors.Add(temp))
            return false;
         //--- Initialize multi-heads attention out
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(mh_out, 0))
            return false;
         if(!AO_Tensors.Add(temp))
            return false;
         //--- Initialize attention out
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(out, 0))
            return false;
         if(!FF_Tensors.Add(temp))
            return false;
         //--- Initialize Feed Forward 1
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(4 * out, 0))
            return false;
         if(!FF_Tensors.Add(temp))
            return false;
         //--- Initialize Feed Forward 2
         if(i == iLayers - 1)
           {
            if(!FF_Tensors.Add(d == 0 ? Output : Gradient))
               return false;
            continue;
           }
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(out, 0))
            return false;
         if(!FF_Tensors.Add(temp))
            return false;
        }
      //--- Initilize QKV weights
      temp = new CBufferFloat();
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      if(!temp.Reserve(qkv_weights))
         return false;
      float k = (float)(1 / sqrt(iWindow + 1));
      for(uint w = 0; w < qkv_weights; w++)
        {
         if(!temp.Add(GenerateWeight() * 2 * k - k))
            return false;
        }
      if(!QKV_Weights.Add(temp))
         return false;
      //--- Initilize Weights0
      temp = new CBufferFloat();
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      if(!temp.Reserve(w0))
         return false;
      for(uint w = 0; w < w0; w++)
        {
         if(!temp.Add(GenerateWeight() * 2 * k - k))
            return false;
        }
      if(!FF_Weights.Add(temp))
         return false;
      //--- Initilize FF Weights
      temp = new CBufferFloat();
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      if(!temp.Reserve(ff_1))
         return false;
      for(uint w = 0; w < ff_1; w++)
        {
         if(!temp.Add(GenerateWeight() * 2 * k - k))
            return false;
        }
      if(!FF_Weights.Add(temp))
         return false;
      //---
      temp = new CBufferFloat();
      if(CheckPointer(temp) == POINTER_INVALID)
         return false;
      if(!temp.Reserve(ff_2))
         return false;
      k = (float)(1 / sqrt(4 * iWindow + 1));
      for(uint w = 0; w < ff_2; w++)
        {
         if(!temp.Add(GenerateWeight() * 2 * k - k))
            return false;
        }
      if(!FF_Weights.Add(temp))
         return false;
      //---
      for(int d = 0; d < (optimization == SGD ? 1 : 2); d++)
        {
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(qkv_weights, 0))
            return false;
         if(!QKV_Weights.Add(temp))
            return false;
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(w0, 0))
            return false;
         if(!FF_Weights.Add(temp))
            return false;
         //--- Initilize FF Weights
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(ff_1, 0))
            return false;
         if(!FF_Weights.Add(temp))
            return false;
         temp = new CBufferFloat();
         if(CheckPointer(temp) == POINTER_INVALID)
            return false;
         if(!temp.BufferInit(ff_2, 0))
            return false;
         if(!FF_Weights.Add(temp))
            return false;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
//---
   for(uint i = 0; (i < iLayers && !IsStopped()); i++)
     {
      //--- Calculate Queries, Keys, Values
      CBufferFloat *inputs = (i == 0 ? NeuronOCL.getOutput() : FF_Tensors.At(6 * i - 4));
      CBufferFloat *qkv = QKV_Tensors.At(i * 2);
      if(IsStopped() || !ConvolutionForward(QKV_Weights.At(i * (optimization == SGD ? 2 : 3)), inputs, qkv, iWindow, 3 * iWindowKey * iHeads, None))
         return false;
      CBufferFloat *temp = QKV_Weights.At(i * (optimization == SGD ? 2 : 3));
      temp.BufferFree();
      //--- Score calculation
      temp = S_Tensors.At(i * 2);
      if(IsStopped() || !AttentionScore(qkv, temp, true))
         return false;
      //--- Multi-heads attention calculation
      CBufferFloat *out = AO_Tensors.At(i * 2);
      if(IsStopped() || !AttentionOut(qkv, temp, out))
         return false;
      qkv.BufferFree();
      temp.BufferFree();
      //--- Attention out calculation
      temp = FF_Tensors.At(i * 6);
      if(IsStopped() || !ConvolutionForward(FF_Weights.At(i * (optimization == SGD ? 6 : 9)), out, temp, iWindowKey * iHeads, iWindow, None))
         return false;
      out.BufferFree();
      //--- Sum and normilize attention
      if(IsStopped() || !SumAndNormilize(temp, inputs, temp))
         return false;
      if(i > 0)
         inputs.BufferFree();
      //--- Feed Forward
      inputs = temp;
      temp = FF_Weights.At(i * (optimization == SGD ? 6 : 9));
      temp.BufferFree();
      temp = FF_Tensors.At(i * 6 + 1);
      if(IsStopped() || !ConvolutionForward(FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 1), inputs, temp, iWindow, 4 * iWindow, LReLU))
         return false;
      out = FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 1);
      out.BufferFree();
      out = FF_Tensors.At(i * 6 + 2);
      if(IsStopped() || !ConvolutionForward(FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 2), temp, out, 4 * iWindow, iWindow, activation))
         return false;
      temp.BufferFree();
      temp = FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 2);
      temp.BufferFree();
      //--- Sum and normilize out
      if(IsStopped() || !SumAndNormilize(out, inputs, out))
         return false;
      inputs.BufferFree();
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::ConvolutionForward(CBufferFloat *weights, CBufferFloat *inputs, CBufferFloat *outputs, uint window, uint window_out, ENUM_ACTIVATION activ)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(weights) == POINTER_INVALID || CheckPointer(inputs) == POINTER_INVALID
      || CheckPointer(outputs) == POINTER_INVALID)
      return false;
//---
   if(!weights.BufferCreate(OpenCL))
      return false;
   if(!inputs.BufferCreate(OpenCL))
      return false;
   if(!outputs.BufferCreate(OpenCL))
      return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = outputs.Total() / window_out;
   OpenCL.SetArgumentBuffer(def_k_FeedForwardConv, def_k_ffc_matrix_w, weights.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForwardConv, def_k_ffc_matrix_i, inputs.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_FeedForwardConv, def_k_ffc_matrix_o, outputs.GetIndex());
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_inputs, inputs.Total());
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_step, window);
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_window_in, window);
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffс_window_out, window_out);
   OpenCL.SetArgument(def_k_FeedForwardConv, def_k_ffc_activation, (int)activ);
   if(!OpenCL.Execute(def_k_FeedForwardConv, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel FeedForwardConv: %d", GetLastError());
      return false;
     }
//---
   return outputs.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::AttentionScore(CBufferFloat *qkv, CBufferFloat *scores, bool mask = true)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(qkv) == POINTER_INVALID || CheckPointer(scores) == POINTER_INVALID)
      return false;
//---
   if(!qkv.BufferCreate(OpenCL))
      return false;
   if(!scores.BufferCreate(OpenCL))
      return false;
//---
   uint global_work_offset[2] = {0, 0};
   uint global_work_size[2];
   global_work_size[0] = iUnits;
   global_work_size[1] = iHeads;
   OpenCL.SetArgumentBuffer(def_k_MHAttentionScore, def_k_mhas_qkv, qkv.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionScore, def_k_mhas_score, scores.GetIndex());
   OpenCL.SetArgument(def_k_MHAttentionScore, def_k_mhas_dimension, iWindowKey);
   OpenCL.SetArgument(def_k_MHAttentionScore, def_k_mhas_mask, (int)mask);
   if(!OpenCL.Execute(def_k_MHAttentionScore, 2, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel MHAttentionScore: %d", GetLastError());
      return false;
     }
//---
   return scores.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::AttentionOut(CBufferFloat *qkv, CBufferFloat *scores, CBufferFloat *out)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(qkv) == POINTER_INVALID || CheckPointer(scores) == POINTER_INVALID
      || CheckPointer(out) == POINTER_INVALID)
      return false;
   uint global_work_offset[2] = {0, 0};
   uint global_work_size[2];
   global_work_size[0] = iUnits;
   global_work_size[1] = iHeads;
   if(!qkv.BufferCreate(OpenCL))
      return false;
   if(!scores.BufferCreate(OpenCL))
      return false;
   if(!out.BufferCreate(OpenCL))
      return false;
//---
   OpenCL.SetArgumentBuffer(def_k_MHAttentionOut, def_k_mhao_qkv, qkv.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionOut, def_k_mhao_score, scores.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionOut, def_k_mhao_out, out.GetIndex());
   OpenCL.SetArgument(def_k_MHAttentionOut, def_k_mhao_dimension, iWindowKey);
   if(!OpenCL.Execute(def_k_MHAttentionOut, 2, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel MHAttentionOut: %d", GetLastError());
      return false;
     }
//---
   return out.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::SumAndNormilize(CBufferFloat *tensor1, CBufferFloat *tensor2, CBufferFloat *out)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(tensor1) == POINTER_INVALID || CheckPointer(tensor2) == POINTER_INVALID
      || CheckPointer(out) == POINTER_INVALID)
      return false;
   if(!tensor1.BufferCreate(OpenCL))
      return false;
   if(!tensor2.BufferCreate(OpenCL))
      return false;
   if(!out.BufferCreate(OpenCL))
      return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = iUnits;
   OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix1, tensor1.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix2, tensor2.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MatrixSum, def_k_sum_matrix_out, out.GetIndex());
   OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_dimension, iWindow);
   OpenCL.SetArgument(def_k_MatrixSum, def_k_sum_multiplyer, 0.5);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_MatrixSum, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel MatrixSum: %d", GetLastError());
      return false;
     }
   if(IsStopped() || !out.BufferRead())
      return false;
//---
   global_work_size[0] = 1;
   if(!OpenCL.SetArgumentBuffer(def_k_Normilize, def_k_norm_buffer, out.GetIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_Normilize, def_k_norm_dimension, out.Total()))
      return false;
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_Normilize, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel Normilize: %d", GetLastError());
      return false;
     }
//---
   return out.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::calcInputGradients(CNeuronBaseOCL *prevLayer)
  {
   if(CheckPointer(prevLayer) == POINTER_INVALID)
      return false;
//---
   CBufferFloat *out_grad = Gradient;
//---
   for(int i = (int)iLayers - 1; (i >= 0 && !IsStopped()); i--)
     {
      //--- Passing gradient through feed forward layers
      if(IsStopped() || !ConvolutionInputGradients(FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 2), out_grad, FF_Tensors.At(i * 6 + 1), FF_Tensors.At(i * 6 + 4), 4 * iWindow, iWindow, None))
         return false;
      CBufferFloat *temp = FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 2);
      temp.BufferFree();
      temp = FF_Tensors.At(i * 6 + 1);
      temp.BufferFree();
      temp = FF_Tensors.At(i * 6 + 3);
      if(IsStopped() || !ConvolutionInputGradients(FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 1), FF_Tensors.At(i * 6 + 4), FF_Tensors.At(i * 6), temp, iWindow, 4 * iWindow, LReLU))
         return false;
      //--- Sum and normilize gradients
      if(IsStopped() || !SumAndNormilize(out_grad, temp, temp))
         return false;
      if(i != (int)iLayers - 1)
         out_grad.BufferFree();
      out_grad = temp;
      temp = FF_Weights.At(i * (optimization == SGD ? 6 : 9) + 1);
      temp.BufferFree();
      temp = FF_Tensors.At(i * 6 + 4);
      temp.BufferFree();
      temp = FF_Tensors.At(i * 6);
      temp.BufferFree();
      //--- Split gradient to multi-heads
      if(IsStopped() || !ConvolutionInputGradients(FF_Weights.At(i * (optimization == SGD ? 6 : 9)), out_grad, AO_Tensors.At(i * 2), AO_Tensors.At(i * 2 + 1), iWindowKey * iHeads, iWindow, None))
         return false;
      temp = FF_Weights.At(i * (optimization == SGD ? 6 : 9));
      temp.BufferFree();
      temp = AO_Tensors.At(i * 2);
      temp.BufferFree();
      //--- Passing gradient to query, key and value
      if(IsStopped() || !AttentionInsideGradients(QKV_Tensors.At(i * 2), QKV_Tensors.At(i * 2 + 1), S_Tensors.At(i * 2), S_Tensors.At(i * 2 + 1), AO_Tensors.At(i * 2 + 1)))
         return false;
      temp = QKV_Tensors.At(i * 2);
      temp.BufferFree();
      temp = S_Tensors.At(i * 2);
      temp.BufferFree();
      temp = S_Tensors.At(i * 2 + 1);
      temp.BufferFree();
      temp = AO_Tensors.At(i * 2 + 1);
      temp.BufferFree();
      //---
      CBufferFloat *inp = NULL;
      if(i == 0)
        {
         inp = prevLayer.getOutput();
         temp = prevLayer.getGradient();
        }
      else
        {
         temp = FF_Tensors.At(i * 6 - 1);
         inp = FF_Tensors.At(i * 6 - 4);
        }
      if(IsStopped() || !ConvolutionInputGradients(QKV_Weights.At(i * (optimization == SGD ? 2 : 3)), QKV_Tensors.At(i * 2 + 1), inp, temp, iWindow, 3 * iWindowKey * iHeads, None))
         return false;
      //--- Sum and normilize gradients
      if(IsStopped() || !SumAndNormilize(out_grad, temp, temp))
         return false;
      out_grad.BufferFree();
      if(i > 0)
         out_grad = temp;
      temp = QKV_Weights.At(i * (optimization == SGD ? 2 : 3));
      temp.BufferFree();
      temp = QKV_Tensors.At(i * 2 + 1);
      temp.BufferFree();
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::ConvolutionInputGradients(CBufferFloat *weights, CBufferFloat *gradient, CBufferFloat *inputs, CBufferFloat *inp_gradient, uint window, uint window_out, uint activ)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(weights) == POINTER_INVALID || CheckPointer(gradient) == POINTER_INVALID || CheckPointer(inputs) == POINTER_INVALID
      || CheckPointer(inp_gradient) == POINTER_INVALID)
      return false;
//---
   if(!weights.BufferCreate(OpenCL))
      return false;
   if(!gradient.BufferCreate(OpenCL))
      return false;
   if(!inputs.BufferCreate(OpenCL))
      return false;
   if(!inp_gradient.BufferCreate(OpenCL))
      return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = inputs.Total();
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_w, weights.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_g, gradient.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_o, inputs.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientConv, def_k_chgc_matrix_ig, inp_gradient.GetIndex());
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_outputs, gradient.Total());
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_step, window);
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_window_in, window);
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_window_out, window_out);
   OpenCL.SetArgument(def_k_CalcHiddenGradientConv, def_k_chgc_activation, activ);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_CalcHiddenGradientConv, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel CalcHiddenGradientConv: %d", GetLastError());
      return false;
     }
//---
   return inp_gradient.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::AttentionInsideGradients(CBufferFloat *qkv, CBufferFloat *qkv_g, CBufferFloat *scores, CBufferFloat *scores_g, CBufferFloat *gradient)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(qkv) == POINTER_INVALID || CheckPointer(qkv_g) == POINTER_INVALID ||
      CheckPointer(scores) == POINTER_INVALID || CheckPointer(scores_g) == POINTER_INVALID || CheckPointer(gradient) == POINTER_INVALID)
      return false;
   uint global_work_offset[2] = {0, 0};
   uint global_work_size[2];
   global_work_size[0] = iUnits;
   global_work_size[1] = iHeads;
   if(!qkv.BufferCreate(OpenCL))
      return false;
   if(!qkv_g.BufferCreate(OpenCL))
      return false;
   if(!scores.BufferCreate(OpenCL))
      return false;
   if(!scores_g.BufferCreate(OpenCL))
      return false;
   if(!gradient.BufferCreate(OpenCL))
      return false;
//---
   OpenCL.SetArgumentBuffer(def_k_MHAttentionGradients, def_k_mhag_qkv, qkv.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionGradients, def_k_mhag_qkv_g, qkv_g.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionGradients, def_k_mhag_score, scores.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionGradients, def_k_mhag_score_g, scores_g.GetIndex());
   OpenCL.SetArgumentBuffer(def_k_MHAttentionGradients, def_k_mhag_gradient, gradient.GetIndex());
   OpenCL.SetArgument(def_k_MHAttentionGradients, def_k_mhag_dimension, iWindowKey);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_MHAttentionGradients, 2, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel MHAttentionGradients: %d", GetLastError());
      return false;
     }
//---
   return (scores_g.BufferRead() && qkv_g.BufferRead());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::updateInputWeights(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
   CBufferFloat *inputs = NeuronOCL.getOutput();
   for(uint l = 0; l < iLayers; l++)
     {
      if(IsStopped() || !ConvolutuionUpdateWeights(QKV_Weights.At(l * (optimization == SGD ? 2 : 3)), QKV_Tensors.At(l * 2 + 1), inputs, (optimization == SGD ? QKV_Weights.At(l * 2 + 1) : QKV_Weights.At(l * 3 + 1)), (optimization == SGD ? NULL : QKV_Weights.At(l * 3 + 2)), iWindow, 3 * iWindowKey * iHeads))
         return false;
      if(l > 0)
         inputs.BufferFree();
      CBufferFloat *temp = QKV_Weights.At(l * (optimization == SGD ? 2 : 3));
      temp.BufferFree();
      temp = QKV_Tensors.At(l * 2 + 1);
      temp.BufferFree();
      if(optimization == SGD)
        {
         temp = QKV_Weights.At(l * 2 + 1);
        }
      else
        {
         temp = QKV_Weights.At(l * 3 + 1);
         temp.BufferFree();
         temp = QKV_Weights.At(l * 3 + 2);
         temp.BufferFree();
        }
      //---
      if(IsStopped() || !ConvolutuionUpdateWeights(FF_Weights.At(l * (optimization == SGD ? 6 : 9)), FF_Tensors.At(l * 6 + 3), AO_Tensors.At(l * 2), (optimization == SGD ? FF_Weights.At(l * 6 + 3) : FF_Weights.At(l * 9 + 3)), (optimization == SGD ? NULL : FF_Weights.At(l * 9 + 6)), iWindowKey * iHeads, iWindow))
         return false;
      temp = FF_Weights.At(l * (optimization == SGD ? 6 : 9));
      temp.BufferFree();
      temp = FF_Tensors.At(l * 6 + 3);
      temp.BufferFree();
      temp = AO_Tensors.At(l * 2);
      temp.BufferFree();
      if(optimization == SGD)
        {
         temp = FF_Weights.At(l * 6 + 3);
         temp.BufferFree();
        }
      else
        {
         temp = FF_Weights.At(l * 9 + 3);
         temp.BufferFree();
         temp = FF_Weights.At(l * 9 + 6);
         temp.BufferFree();
        }
      //---
      if(IsStopped() || !ConvolutuionUpdateWeights(FF_Weights.At(l * (optimization == SGD ? 6 : 9) + 1), FF_Tensors.At(l * 6 + 4), FF_Tensors.At(l * 6), (optimization == SGD ? FF_Weights.At(l * 6 + 4) : FF_Weights.At(l * 9 + 4)), (optimization == SGD ? NULL : FF_Weights.At(l * 9 + 7)), iWindow, 4 * iWindow))
         return false;
      temp = FF_Weights.At(l * (optimization == SGD ? 6 : 9) + 1);
      temp.BufferFree();
      temp = FF_Tensors.At(l * 6 + 4);
      temp.BufferFree();
      temp = FF_Tensors.At(l * 6);
      temp.BufferFree();
      if(optimization == SGD)
        {
         temp = FF_Weights.At(l * 6 + 4);
         temp.BufferFree();
        }
      else
        {
         temp = FF_Weights.At(l * 9 + 4);
         temp.BufferFree();
         temp = FF_Weights.At(l * 9 + 7);
         temp.BufferFree();
        }
      //---
      if(IsStopped() || !ConvolutuionUpdateWeights(FF_Weights.At(l * (optimization == SGD ? 6 : 9) + 2), FF_Tensors.At(l * 6 + 5), FF_Tensors.At(l * 6 + 1), (optimization == SGD ? FF_Weights.At(l * 6 + 5) : FF_Weights.At(l * 9 + 5)), (optimization == SGD ? NULL : FF_Weights.At(l * 9 + 8)), 4 * iWindow, iWindow))
         return false;
      temp = FF_Weights.At(l * (optimization == SGD ? 6 : 9) + 2);
      temp.BufferFree();
      temp = FF_Tensors.At(l * 6 + 5);
      if(temp != Gradient)
         temp.BufferFree();
      temp = FF_Tensors.At(l * 6 + 1);
      temp.BufferFree();
      if(optimization == SGD)
        {
         temp = FF_Weights.At(l * 6 + 5);
         temp.BufferFree();
        }
      else
        {
         temp = FF_Weights.At(l * 9 + 5);
         temp.BufferFree();
         temp = FF_Weights.At(l * 9 + 8);
         temp.BufferFree();
        }
      inputs = FF_Tensors.At(l * 6 + 2);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::ConvolutuionUpdateWeights(CBufferFloat *weights, CBufferFloat *gradient, CBufferFloat *inputs, CBufferFloat *momentum1, CBufferFloat *momentum2, uint window, uint window_out)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(weights) == POINTER_INVALID || CheckPointer(gradient) == POINTER_INVALID || CheckPointer(inputs) == POINTER_INVALID  || CheckPointer(momentum1) == POINTER_INVALID)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = weights.Total();
   if(!weights.BufferCreate(OpenCL))
      return false;
   if(optimization == SGD)
     {
      if(!gradient.BufferCreate(OpenCL))
         return false;
      if(!inputs.BufferCreate(OpenCL))
         return false;
      if(!momentum1.BufferCreate(OpenCL))
         return false;
      OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_w, weights.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_g, gradient.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_i, inputs.GetIndex());
      OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvMomentum, def_k_uwcm_matrix_dw, momentum1.GetIndex());
      OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_inputs, inputs.Total());
      OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_learning_rates, eta);
      OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_momentum, alpha);
      OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_window_in, window);
      OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_window_out, window_out);
      OpenCL.SetArgument(def_k_UpdateWeightsConvMomentum, def_k_uwcm_step, window);
      ResetLastError();
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_UpdateWeightsConvMomentum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel UpdateWeightsConvMomentum: %d", GetLastError());
         return false;
        }
      if(!momentum1.BufferRead())
         return false;
     }
   else
     {
      global_work_size[0] = window + 1;
      if(CheckPointer(momentum2) == POINTER_INVALID)
         return false;
      if(!gradient.BufferCreate(OpenCL))
         return false;
      if(!inputs.BufferCreate(OpenCL))
         return false;
      if(!momentum1.BufferCreate(OpenCL))
         return false;
      if(!momentum2.BufferCreate(OpenCL))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_w, weights.GetIndex()))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_g, gradient.GetIndex()))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_i, inputs.GetIndex()))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_m, momentum1.GetIndex()))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateWeightsConvAdam, def_k_uwca_matrix_v, momentum2.GetIndex()))
         return false;
      float lt = (float)(eta * sqrt(1 - pow(b2, t)) / (1 - pow(b1, t)));
      if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwa_inputs, inputs.Total()))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_l, lt))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_b1, b1))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_b2, b2))
         return false;
      OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_window_in, window);
      OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_window_out, window_out);
      OpenCL.SetArgument(def_k_UpdateWeightsConvAdam, def_k_uwca_step, window);
      ResetLastError();
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_UpdateWeightsConvAdam, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel UpdateWeightsConvAdam: %d", GetLastError());
         return false;
        }
      if(!momentum1.BufferRead() || !momentum2.BufferRead())
         return false;
      t++;
     }
//---
   global_work_size[0] = window_out;
   OpenCL.SetArgumentBuffer(def_k_NormilizeWeights, def_k_norm_buffer, weights.GetIndex());
   OpenCL.SetArgument(def_k_NormilizeWeights, def_k_norm_dimension, window + 1);
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_NormilizeWeights, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel Normalize: %d", GetLastError());
      return false;
     }
//---
   return weights.BufferRead();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::Save(const int file_handle)
  {
   if(!CNeuronBaseOCL::Save(file_handle))
      return false;
//--- Saving constants
   if(!FileWriteInteger(file_handle, iLayers, INT_VALUE) || !FileWriteInteger(file_handle, iHeads, INT_VALUE) || !FileWriteInteger(file_handle, iWindow, INT_VALUE) ||
      !FileWriteInteger(file_handle, iUnits, INT_VALUE) || !FileWriteInteger(file_handle, iWindowKey, INT_VALUE))
      return false;
//--- Saving objects
   if(!QKV_Tensors.Save(file_handle) || !QKV_Weights.Save(file_handle) || !S_Tensors.Save(file_handle) || !AO_Tensors.Save(file_handle) ||
      !FF_Tensors.Save(file_handle) || !FF_Weights.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronMLMHAttentionOCL::Load(const int file_handle)
  {
   if(!CNeuronBaseOCL::Load(file_handle))
      return false;
//--- Loading constants
   iLayers = FileReadInteger(file_handle, INT_VALUE);
   iHeads = FileReadInteger(file_handle, INT_VALUE);
   iWindow = FileReadInteger(file_handle, INT_VALUE);
   iUnits = FileReadInteger(file_handle, INT_VALUE);
   iWindowKey = FileReadInteger(file_handle, INT_VALUE);
//--- Loading objects
   if(!QKV_Tensors.Load(file_handle) || !QKV_Weights.Load(file_handle) || !S_Tensors.Load(file_handle) || !AO_Tensors.Load(file_handle) ||
      !FF_Tensors.Load(file_handle) || !FF_Weights.Load(file_handle))
      return false;
//---
   Output = FF_Tensors.At(iLayers * 6 - 4);
   Gradient = FF_Tensors.At(iLayers * 6 - 1);
   if(CheckPointer(Output) == POINTER_INVALID || !Output.BufferCreate(OpenCL) ||
      CheckPointer(Gradient) == POINTER_INVALID || !Gradient.BufferCreate(OpenCL))
     {
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronMLMHAttentionOCL::GetLayerInfo(void)
  {
   CLayerDescription* result = CNeuronBaseOCL::GetLayerInfo();
   if(!result)
      return result;
//---
   result.window = (int)iWindow;
   result.step = (int)iHeads;
   result.window_out = (int)iWindowKey;
   result.count = (int)iUnits;
   result.layers = (int)iLayers;
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CNeuronBaseOCL::GenerateWeight(void)
  {
   xor128;
   float result = (float)rnd_w / UINT_MAX;
   if(result == 0)
      result = GenerateWeight();
//---
   return result;
  }
//+------------------------------------------------------------------+
///\ingroup neuron_base
///\class CNeuronDropoutOCL
///\brief The Dropout neuron for GPU calculation.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9112#para2">the link.</A>
//+------------------------------------------------------------------+
class CNeuronDropoutOCL    :  public   CNeuronBaseOCL
  {
protected:
   CNeuronBaseOCL    *PrevLayer;
   float             OutProbability;
   int               OutNumber;
   CBufferFloat      *DropOutMultiplier;
   float             dInitValue;
   //---
   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL);               ///< \brief Feed Forward method.@param NeuronOCL Pointer to previos layer.
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL) {return true;}        ///< Blank method for updating weights.@param NeuronOCL Pointer to previos layer.
   //---
   int               RND(void)   { xor128; return (int)((float)(Neurons() - 1) / UINT_MAX * rnd_w);  } ///< Generates a random neuron position to turn off

public:
   /** Constructor */
                     CNeuronDropoutOCL(void);
   /** Destructor */
                    ~CNeuronDropoutOCL(void);
   //---
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, float out_prob, ENUM_OPTIMIZATION optimization_type, uint batch);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object. #param[in] numNeurons Number of neurons in layer #param[in] out_prob Probability of neurons shutdown @param optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   //---
   virtual int       getOutputIndex(void)          {  return (bTrain ? Output.GetIndex() : PrevLayer.getOutputIndex());             }  ///< Get index of output buffer @return Index
   virtual int       getGradientIndex(void)        {  return (bTrain ? Gradient.GetIndex() : PrevLayer.getGradientIndex());          }  ///< Get index of gradient buffer @return Index
   //---
   virtual int       getOutputVal(float &values[])   {  return (bTrain ? Output.GetData(values) : PrevLayer.getOutputVal(values)); }  ///< Get values of output buffer @param[out] values Array of data @return number of items
   virtual int       getOutputVal(CArrayFloat *values)   {  return (bTrain ? Output.GetData(values) : PrevLayer.getOutputVal(values)); }  ///< Get values of output buffer @param[out] values Array of data @return number of items
   virtual int       getGradient(float &values[])    {  return (bTrain ? Gradient.GetData(values) : PrevLayer.getGradient(values));    }  ///< Get values of gradient buffer @param[out] values Array of data @return number of items
   virtual CBufferFloat   *getOutput(void)           {  return (bTrain ? Output : PrevLayer.getOutput());      }                 ///< Get pointer of output buffer @return Pointer to object
   virtual CBufferFloat   *getGradient(void)         {  return (bTrain ? Gradient : PrevLayer.getGradient());  }                 ///< Get pointer of gradient buffer @return Pointer to object
   //---
   virtual bool      calcInputGradients(CNeuronBaseOCL *NeuronOCL);          ///< Method to transfer gradient to previous layer by calling kernel ::CalcHiddenGradient(). @param NeuronOCL Pointer to next layer.
   //---
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   //---
   virtual int       Type(void)        const                      {  return defNeuronDropoutOCL;                }///< Identificator of class.@return Type of class
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNeuronDropoutOCL::CNeuronDropoutOCL(void) :  OutProbability((float)0.1),
   OutNumber(0),
   dInitValue(1.0)
  {
   PrevLayer = NULL;
   DropOutMultiplier = new CBufferFloat();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNeuronDropoutOCL::~CNeuronDropoutOCL(void)
  {
   if(CheckPointer(DropOutMultiplier) != POINTER_INVALID)
      delete DropOutMultiplier;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronDropoutOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, float out_prob, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(!CNeuronBaseOCL::Init(numOutputs, myIndex, open_cl, numNeurons, optimization_type, batch))
      return false;
   OutProbability = out_prob;
   OutNumber = (int)(numNeurons * out_prob);
   dInitValue = 1 / (1 - OutProbability);
   if(CheckPointer(DropOutMultiplier) == POINTER_INVALID)
      DropOutMultiplier = new CBufferFloat();
   if(!DropOutMultiplier.BufferInit(numNeurons + 1, dInitValue))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronDropoutOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
//---
   activation = (ENUM_ACTIVATION)NeuronOCL.Activation();
   PrevLayer = NeuronOCL;
   if(!bTrain)
      return true;
//---
   if(CheckPointer(DropOutMultiplier) == POINTER_INVALID)
      DropOutMultiplier = new CBufferFloat();
   if(!DropOutMultiplier.BufferInit(NeuronOCL.Neurons(), dInitValue))
      return false;
   for(int i = 0; i < OutNumber; i++)
     {
      uint p = RND();
      float val = DropOutMultiplier.At(p);
      if(val == 0 || val == DBL_MAX)
        {
         i--;
         continue;
        }
      if(!DropOutMultiplier.Update(RND(), 0))
         return false;
     }
//---
   if(!DropOutMultiplier.BufferCreate(OpenCL))
      return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   int i = Neurons() % 4;
   global_work_size[0] = (Neurons() - i) / 4 + (i > 0 ? 1 : 0);
   if(!OpenCL.SetArgumentBuffer(def_k_Dropout, def_k_dout_input, NeuronOCL.getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_Dropout, def_k_dout_map, DropOutMultiplier.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_Dropout, def_k_dout_out, Output.GetIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_Dropout, def_k_dout_dimension, Neurons()))
      return false;
   ResetLastError();
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_Dropout, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel Dropout: %d", GetLastError());
      return false;
     }
   if(!Output.BufferRead())
      return false;
   DropOutMultiplier.BufferFree();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronDropoutOCL::calcInputGradients(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
//---
   if(!bTrain)
      return true;
//---
   if(CheckPointer(DropOutMultiplier) == POINTER_INVALID)
      return false;
//---
   if(!DropOutMultiplier.BufferCreate(OpenCL))
      return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   int i = Neurons() % 4;
   global_work_size[0] = (Neurons() - i) / 4 + (i > 0 ? 1 : 0);
   if(!OpenCL.SetArgumentBuffer(def_k_Dropout, def_k_dout_input, Gradient.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_Dropout, def_k_dout_map, DropOutMultiplier.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_Dropout, def_k_dout_out, NeuronOCL.getGradientIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_Dropout, def_k_dout_dimension, Neurons()))
      return false;
   ResetLastError();
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_Dropout, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel Dropout: %d", GetLastError());
      return false;
     }
   if(!NeuronOCL.getGradient().BufferRead())
      return false;
   DropOutMultiplier.BufferFree();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronDropoutOCL::Save(const int file_handle)
  {
   if(!CNeuronBaseOCL::Save(file_handle))
      return false;
//---
   if(FileWriteDouble(file_handle, OutProbability) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronDropoutOCL::Load(const int file_handle)
  {
   if(!CNeuronBaseOCL::Load(file_handle))
      return false;
//---
   OutProbability = (float)FileReadDouble(file_handle);
   OutNumber = (int)(Neurons() * OutProbability);
   dInitValue = 1 / (1 - OutProbability);
   if(CheckPointer(DropOutMultiplier) == POINTER_INVALID)
      DropOutMultiplier = new CBufferFloat();
   if(!DropOutMultiplier.BufferInit(Neurons() + 1, dInitValue))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronDropoutOCL::GetLayerInfo(void)
  {
   CLayerDescription* result = CNeuronBaseOCL::GetLayerInfo();
   if(!result)
      return result;
//---
   result.probability = OutProbability;
//---
   return result;
  }
//+------------------------------------------------------------------+
///\class CNeuronBatchNormOCL
///\brief The class of Batch Normalization neuron for GPU calculation.
///\details Detailed description on <A HREF="https://www.mql5.com/ru/articles/9207#para4">the link.</A>
//+------------------------------------------------------------------+
class CNeuronBatchNormOCL  :  public CNeuronBaseOCL
  {
protected:
   CNeuronBaseOCL    *PrevLayer;       ///< Pointer to the object of the previous layer
   uint              iBatchSize;       ///< Batch size
   CBufferFloat      *BatchOptions;    ///< Container of method parameters

   ///\ingroup neuron_base_ff
   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL);               ///< \brief Feed Forward method of calling kernel ::BatchFeedForward().@param NeuronOCL Pointer to previos layer.

   ///\ingroup neuron_base_opt
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL);        ///< Method for updating weights.\details Calling one of kernels ::UpdateBatchOptionsMomentum() or ::UpdateBatchOptionsAdam() in depends of optimization type (#ENUM_OPTIMIZATION).@param NeuronOCL Pointer to previos layer.

public:
   /** Constructor */
                     CNeuronBatchNormOCL(void);
   /** Destructor */~CNeuronBatchNormOCL(void);
   //---
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, uint batchSize, ENUM_OPTIMIZATION optimization_type);
   ///< Method of initialization class.@param[in] numOutputs Number of connections to next layer.@param[in] myIndex Index of neuron in layer.@param[in] open_cl Pointer to #COpenCLMy object. #param[in] numNeurons Number of neurons in layer @param optimization_type Optimization type (#ENUM_OPTIMIZATION)@return Boolen result of operations.
   //---
   virtual int       getOutputIndex(void)          {  return (iBatchSize > 1 ? Output.GetIndex() : PrevLayer.getOutputIndex());             } ///< Get index of output buffer @return Index
   virtual int       getGradientIndex(void)        {  return (iBatchSize > 1 ? Gradient.GetIndex() : PrevLayer.getGradientIndex());          } ///< Get index of gradient buffer @return Index
   //---
   virtual int       getOutputVal(float &values[])   {  return (iBatchSize > 1 ? Output.GetData(values) : PrevLayer.getOutputVal(values)); } ///< Get values of output buffer @param[out] values Array of data @return number of items
   virtual int       getOutputVal(CArrayFloat *values)   {  return (iBatchSize > 1 ? Output.GetData(values) : PrevLayer.getOutputVal(values)); } ///< Get values of output buffer @param[out] values Array of data @return number of items
   virtual int       getGradient(float &values[])    {  return (iBatchSize > 1 ? Gradient.GetData(values) : PrevLayer.getGradient(values));    } ///< Get values of gradient buffer @param[out] values Array of data @return number of items
   virtual CBufferFloat   *getOutput(void)           {  return (iBatchSize > 1 ? Output : PrevLayer.getOutput());      }               ///< Get pointer of output buffer @return Pointer to object
   virtual CBufferFloat   *getGradient(void)         {  return (iBatchSize > 1 ? Gradient : PrevLayer.getGradient());  }               ///< Get pointer of gradient buffer @return Pointer to object
   //---
   virtual bool      calcInputGradients(CNeuronBaseOCL *NeuronOCL);          ///< Method to transfer gradient to previous layer by calling kernel ::CalcHiddenGradientBatch(). @param NeuronOCL Pointer to next layer.
   //---
   virtual bool      Save(int const file_handle);///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle);///< Load method @param[in] file_handle handle of file @return logical result of operation
   //---
   virtual int       Type(void)        const                      {  return defNeuronBatchNormOCL;    }///< Identificator of class.@return Type of class
   virtual CLayerDescription* GetLayerInfo(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronBatchNormOCL::CNeuronBatchNormOCL(void)  :  iBatchSize(1)
  {
   PrevLayer = NULL;
   BatchOptions = NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronBatchNormOCL::~CNeuronBatchNormOCL(void)
  {
   if(CheckPointer(PrevLayer) != POINTER_INVALID)
      PrevLayer = NULL;
   if(CheckPointer(BatchOptions) != POINTER_INVALID)
      delete BatchOptions;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNormOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, uint batchSize, ENUM_OPTIMIZATION optimization_type)
  {
   if(!CNeuronBaseOCL::Init(numOutputs, myIndex, open_cl, numNeurons, optimization_type, batchSize))
      return false;
   activation = None;
   iBatchSize = batchSize;
//---
   if(CheckPointer(BatchOptions) != POINTER_INVALID)
      delete BatchOptions;
   int count = (int)numNeurons * (optimization_type == SGD ? 7 : 9);
   BatchOptions = new CBufferFloat();
   if(!BatchOptions.BufferInit(count, 0))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNormOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
//---
   PrevLayer = NeuronOCL;
   if(iBatchSize <= 1)
     {
      activation = (ENUM_ACTIVATION)NeuronOCL.Activation();
      return true;
     }
//---
   if(CheckPointer(BatchOptions) == POINTER_INVALID)
     {
      int count = Neurons() * (optimization == SGD ? 7 : 9);
      BatchOptions = new CBufferFloat();
      if(!BatchOptions.BufferInit(count, 0))
         return false;
     }
//if(!BatchOptions.BufferCreate(OpenCL))
//   return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Neurons();
   if(!OpenCL.SetArgumentBuffer(def_k_BatchFeedForward, def_k_bff_inputs, NeuronOCL.getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_BatchFeedForward, def_k_bff_options, BatchOptions.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_BatchFeedForward, def_k_bff_output, Output.GetIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_BatchFeedForward, def_k_bff_batch, iBatchSize))
      return false;
   if(!OpenCL.SetArgument(def_k_BatchFeedForward, def_k_bff_optimization, (int)optimization))
      return false;
   if(!OpenCL.SetArgument(def_k_BatchFeedForward, def_k_bff_activation, (int)activation))
      return false;
   ResetLastError();
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_BatchFeedForward, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel Batch Feed Forward: %d", GetLastError());
      return false;
     }
//if(!Output.BufferRead() || !BatchOptions.BufferRead())
//   return false;
//BatchOptions.BufferFree();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNormOCL::calcInputGradients(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
//---
   if(iBatchSize <= 1)
      return (CheckPointer(PrevLayer) != POINTER_INVALID);
//---
   if(CheckPointer(BatchOptions) == POINTER_INVALID || BatchOptions.GetIndex() < 0)
      return false;
//---
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Neurons();
   if(!OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientBatch, def_k_bchg_matrix_i, NeuronOCL.getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientBatch, def_k_bchg_options, BatchOptions.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientBatch, def_k_bchg_matrix_g, Gradient.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_CalcHiddenGradientBatch, def_k_bchg_matrix_ig, NeuronOCL.getGradientIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_CalcHiddenGradientBatch, def_k_bchg_activation, NeuronOCL.Activation()))
      return false;
   if(!OpenCL.SetArgument(def_k_CalcHiddenGradientBatch, def_k_bchg_batch, iBatchSize))
      return false;
   if(!OpenCL.SetArgument(def_k_CalcHiddenGradientBatch, def_k_bchg_optimization, (int)optimization))
      return false;
   ResetLastError();
//Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
   if(!OpenCL.Execute(def_k_CalcHiddenGradientBatch, 1, global_work_offset, global_work_size))
     {
      printf("Error of execution kernel Batch CalcHiddenGradient: %d", GetLastError());
      return false;
     }
//if(!NeuronOCL.getGradient().BufferRead())
//   return false;
//BatchOptions.BufferFree();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNormOCL::updateInputWeights(CNeuronBaseOCL *NeuronOCL)
  {
   if(CheckPointer(OpenCL) == POINTER_INVALID || CheckPointer(NeuronOCL) == POINTER_INVALID)
      return false;
//---
   if(iBatchSize <= 1)
      return (CheckPointer(PrevLayer) != POINTER_INVALID);
//---
   if(CheckPointer(BatchOptions) == POINTER_INVALID || BatchOptions.GetIndex() < 0)
      return false;
   uint global_work_offset[1] = {0};
   uint global_work_size[1];
   global_work_size[0] = Neurons();
//---
   if(optimization == SGD)
     {
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateBatchOptionsMomentum, def_k_buom_options, BatchOptions.GetIndex()))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateBatchOptionsMomentum, def_k_buom_matrix_g, Gradient.GetIndex()))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateBatchOptionsMomentum, def_k_buom_learning_rates, eta))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateBatchOptionsMomentum, def_k_buom_momentum, alpha))
         return false;
      ResetLastError();
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_UpdateBatchOptionsMomentum, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel UpdateBatchOptionsMomentum %d", GetLastError());
         return false;
        }
     }
   else
     {
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateBatchOptionsAdam, def_k_buoa_options, BatchOptions.GetIndex()))
         return false;
      if(!OpenCL.SetArgumentBuffer(def_k_UpdateBatchOptionsAdam, def_k_buoa_matrix_g, Gradient.GetIndex()))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateBatchOptionsAdam, def_k_buoa_l, lr))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateBatchOptionsAdam, def_k_buoa_b1, b1))
         return false;
      if(!OpenCL.SetArgument(def_k_UpdateBatchOptionsAdam, def_k_buoa_b2, b2))
         return false;
      ResetLastError();
      //Comment(com+"\n "+(string)__LINE__+"-"__FUNCTION__);
      if(!OpenCL.Execute(def_k_UpdateBatchOptionsAdam, 1, global_work_offset, global_work_size))
        {
         printf("Error of execution kernel UpdateBatchOptionsAdam %d", GetLastError());
         return false;
        }
     }
//---
//if(!BatchOptions.BufferRead())
//   return false;
//BatchOptions.BufferFree();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNormOCL::Save(const int file_handle)
  {
   if(!CNeuronBaseOCL::Save(file_handle))
      return false;
//---
   if(FileWriteInteger(file_handle, iBatchSize, INT_VALUE) <= 0)
      return false;
   if(!BatchOptions.BufferRead())
     return false;
   return BatchOptions.Save(file_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNormOCL::Load(const int file_handle)
  {
   if(!CNeuronBaseOCL::Load(file_handle))
      return false;
//---
   iBatchSize = FileReadInteger(file_handle, INT_VALUE);
   if(!BatchOptions.Load(file_handle))
      return false;
   if(!!OpenCL && !BatchOptions.BufferCreate(OpenCL))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLayerDescription* CNeuronBatchNormOCL::GetLayerInfo(void)
  {
   CLayerDescription* result = CNeuronBaseOCL::GetLayerInfo();
   if(!result)
      return result;
//---
   result.batch = (int)iBatchSize;
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MHAttentionOutCPU(CArrayFloat *scores, ///<[in] Matrix of Scores
                       CArrayFloat *qkv,    ///<[in] Matrix of Values
                       CArrayFloat *out,    ///<[out] Output tesor
                       int dimension,            ///< Dimension of Value
                       int units,
                       int heads
                      )
  {
   for(int u = 0; u < units; u++)
      for(int h = 0; h < heads; h++)
        {
         //---
         int shift_s = units * (h + heads * u);
         int shift_out = dimension * (h + heads * u);
         int layer = 3 * dimension * heads;
         //---
         for(int d = 0; d < dimension; d++)
           {
            float result = 0;
            for(int v = 0; v < units; v++)
              {
               int shift_v = dimension * (h + heads * (3 * v + 2)) + d;
               //if((units-v)>4)
               //  {
               //   result+=dot((float4)(scores[shift_s+v],scores[shift_s+v+1],scores[shift_s+v+1],scores[shift_s+v+3]),
               //                     (float4)(qkv[shift_v],qkv[shift_v+layer],qkv[shift_v+2*layer],qkv[shift_v+3*layer]));
               //  }
               //else
               //for(int l=0;l<(int)fmin((float)(units-v),4.0);l++)
               result += scores[shift_s + v] * qkv[shift_v];
              }
            out.Update(shift_out + d, result);
           }
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNet::GetLayerOutput(uint layer, CBufferFloat *&result)
  {
   if(!layers || layers.Total() <= (int)layer)
      return false;
   CLayer *Layer = layers.At(layer);
   if(!Layer)
      return false;
//---
   if(!result)
     {
      result = new CBufferFloat();
      if(!result)
         return false;
     }
//---
   CNeuronBaseOCL *temp = Layer.At(0);
   if(!temp || temp.getOutputVal(result) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNeuronLSTMOCL : public CNeuronBaseOCL
  {
protected:
   CBufferFloat      m_cWeightsLSTM;
   CBufferFloat      m_cFirstMomentumLSTM;      ///< Buffer of first momentum matrix (#ADAM) or last delta weights matrix (#SGD)
   CBufferFloat      m_cSecondMomentumLSTM;     ///< Buffer of second momentum matrix (#ADAM)

   int               m_iMemory;
   int               m_iConcatenated;
   int               m_iConcatenatedGradient;
   int               m_iHiddenState;
   int               m_iInputs;
   int               m_iWeightsGradient;
   ///\ingroup neuron_base_ff
   virtual bool      feedForward(CNeuronBaseOCL *NeuronOCL) override;               ///< \brief Feed Forward method.@param NeuronOCL Pointer to previos layer.

   ///\ingroup neuron_base_opt
   virtual bool      updateInputWeights(CNeuronBaseOCL *NeuronOCL) override;        ///< Method for updating weights.

public:
                     CNeuronLSTMOCL(void);
                    ~CNeuronLSTMOCL(void);
   //---
   virtual bool      Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, ENUM_OPTIMIZATION optimization_type, uint batch) override;
   virtual bool      SetInputs(int count);
   //---
   virtual bool      calcInputGradients(CNeuronBaseOCL *NeuronOCL);          ///< Method to transfer gradient to previous layer by calling kernel ::CalcHiddenGradient(). @param NeuronOCL Pointer to next layer.
   ///@}
   //---
   virtual bool      Save(int const file_handle) override;///< Save method @param[in] file_handle handle of file @return logical result of operation
   virtual bool      Load(int const file_handle) override;///< Load method @param[in] file_handle handle of file @return logical result of operation
   //---
   virtual int       Type(void) override       const                      {  return defNeuronLSTMOCL;                  }///< Identificator of class.@return Type of class
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronLSTMOCL::CNeuronLSTMOCL(void)   :  m_iMemory(-1),
   m_iConcatenated(-1),
   m_iConcatenatedGradient(-1),
   m_iHiddenState(-1),
   m_iInputs(-1)
  {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNeuronLSTMOCL::~CNeuronLSTMOCL(void)
  {
   if(!OpenCL)
      return;
   OpenCL.BufferFree(m_iConcatenated);
   OpenCL.BufferFree(m_iConcatenatedGradient);
   OpenCL.BufferFree(m_iHiddenState);
   OpenCL.BufferFree(m_iMemory);
   OpenCL.BufferFree(m_iWeightsGradient);
   m_cFirstMomentumLSTM.BufferFree();
   m_cSecondMomentumLSTM.BufferFree();
   m_cWeightsLSTM.BufferFree();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::Init(uint numOutputs, uint myIndex, COpenCLMy *open_cl, uint numNeurons, ENUM_OPTIMIZATION optimization_type, uint batch)
  {
   if(!CNeuronBaseOCL::Init(numOutputs, myIndex, open_cl, numNeurons, optimization_type, batch))
      return false;
//---
   m_iMemory = OpenCL.AddBuffer(sizeof(float) * numNeurons * 2, CL_MEM_READ_WRITE);
   if(m_iMemory < 0)
      return false;
   m_iHiddenState = OpenCL.AddBuffer(sizeof(float) * numNeurons, CL_MEM_READ_WRITE);
   if(m_iHiddenState < 0)
      return false;
   m_iConcatenated = OpenCL.AddBuffer(sizeof(float) * numNeurons * 4, CL_MEM_READ_WRITE);
   if(m_iConcatenated < 0)
      return false;
   m_iConcatenatedGradient = OpenCL.AddBuffer(sizeof(float) * numNeurons * 4, CL_MEM_READ_WRITE);
   if(m_iConcatenatedGradient < 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::feedForward(CNeuronBaseOCL *NeuronOCL)
  {
   if(!NeuronOCL || NeuronOCL.Neurons() <= 0 ||
      NeuronOCL.getOutputIndex() < 0 || !OpenCL)
      return false;
//---
   if(m_iInputs <= 0)
     {
      if(!SetInputs(NeuronOCL.Neurons()))
         return false;
     }
   else
      if(m_iInputs != NeuronOCL.Neurons())
         return false;
//---
   if(m_iMemory < 0 || m_iConcatenated < 0)
      return false;
//---
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_FeedForward, def_k_lstmff_inputs, NeuronOCL.getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_FeedForward, def_k_lstmff_concatenated, m_iConcatenated))
      return false;
   if(!OpenCL.SetArgument(def_k_LSTM_FeedForward, def_k_lstmff_inputs_size, m_iInputs))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_FeedForward, def_k_lstmff_memory, m_iMemory))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_FeedForward, def_k_lstmff_outputs, getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_FeedForward, def_k_lstmff_weights, m_cWeightsLSTM.GetIndex()))
      return false;
   uint global_work_offset[] = {0, 0};
   uint global_work_size[] = {Neurons(), 4};
   uint local_work_size[] = {1, 4};
   if(!OpenCL.Execute(def_k_LSTM_FeedForward, 2, global_work_offset, global_work_size, local_work_size))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::SetInputs(int count)
  {
   m_iInputs = count;
   count = (int)((m_iInputs + Neurons() + 1) * Neurons());
   if(!m_cWeightsLSTM.Reserve(count))
      return false;
   float k = (float)(1 / sqrt(Neurons() + 1));
   for(int i = 0; i < count; i++)
     {
      if(!m_cWeightsLSTM.Add((2 * GenerateWeight()*k - k)*WeightsMultiplier))
         return false;
     }
   if(!m_cWeightsLSTM.BufferCreate(OpenCL))
      return false;
//---
   if(!m_cFirstMomentumLSTM.BufferInit(count, 0))
      return false;
   if(!m_cFirstMomentumLSTM.BufferCreate(OpenCL))
      return false;
//---
   if(!m_cSecondMomentumLSTM.BufferInit(count, 0))
      return false;
   if(!m_cSecondMomentumLSTM.BufferCreate(OpenCL))
      return false;
   if(m_iWeightsGradient >= 0)
      OpenCL.BufferFree(m_iWeightsGradient);
   m_iWeightsGradient = OpenCL.AddBuffer(sizeof(float) * count, CL_MEM_READ_WRITE);
   if(m_iWeightsGradient < 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::calcInputGradients(CNeuronBaseOCL *NeuronOCL)
  {
   if(!NeuronOCL || NeuronOCL.Neurons() <= 0 || NeuronOCL.getGradientIndex() < 0 ||
      NeuronOCL.getOutputIndex() < 0 || !OpenCL)
      return false;
//---
   if(m_cWeightsLSTM.GetIndex() < 0 || m_cFirstMomentumLSTM.GetIndex() < 0 ||
      m_cSecondMomentumLSTM.GetIndex() < 0)
      return false;
   if(m_iInputs < 0 || m_iConcatenated < 0 || m_iMemory < 0 ||
      m_iConcatenatedGradient < 0 || m_iHiddenState < 0 || m_iInputs != NeuronOCL.Neurons())
      return false;
//---
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_ConcatenatedGradient, def_k_lstmcg_concatenated, m_iConcatenated))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_ConcatenatedGradient, def_k_lstmcg_concatenated_gradient, m_iConcatenatedGradient))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_ConcatenatedGradient, def_k_lstmcg_gradient, getGradientIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_ConcatenatedGradient, def_k_lstmcg_memory, m_iMemory))
      return false;
   uint global_work_offset[] = {0};
   uint global_work_size[] = {Neurons()};
   if(!OpenCL.Execute(def_k_LSTM_ConcatenatedGradient, 1, global_work_offset, global_work_size))
      return false;
//---
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_concatenated_gradient, m_iConcatenatedGradient))
      return false;
   if(!OpenCL.SetArgument(def_k_LSTM_HiddenGradient, def_k_lstmhg_hidden_size, Neurons()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_hidden_state, m_iHiddenState))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_inputs, NeuronOCL.getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_inputs_gradient, NeuronOCL.getGradientIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_LSTM_HiddenGradient, def_k_lstmhg_inputs_size, m_iInputs))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_output, getOutputIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_weeights, m_cWeightsLSTM.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_HiddenGradient, def_k_lstmhg_weights_gradient, m_iWeightsGradient))
      return false;
   if(!OpenCL.Execute(def_k_LSTM_HiddenGradient, 1, global_work_offset, global_work_size))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::updateInputWeights(CNeuronBaseOCL *NeuronOCL)
  {
   if(!OpenCL || m_cWeightsLSTM.GetIndex() < 0 || m_iWeightsGradient < 0 ||
      m_cFirstMomentumLSTM.GetIndex() < 0 || m_cSecondMomentumLSTM.GetIndex() < 0)
      return false;
//---
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_weights, m_cWeightsLSTM.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_weights_gradient, m_iWeightsGradient))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_matrix_m, m_cFirstMomentumLSTM.GetIndex()))
      return false;
   if(!OpenCL.SetArgumentBuffer(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_matrix_v, m_cSecondMomentumLSTM.GetIndex()))
      return false;
   if(!OpenCL.SetArgument(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_l, lr))
      return false;
   if(!OpenCL.SetArgument(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_b1, b1))
      return false;
   if(!OpenCL.SetArgument(def_k_LSTM_UpdateWeightsAdam, def_k_lstmuw_b2, b2))
      return false;
   uint global_work_offset[] = {0, 0};
   uint global_work_size[] = {m_iInputs + Neurons() + 1, Neurons()};
   if(!OpenCL.Execute(def_k_LSTM_UpdateWeightsAdam, 2, global_work_offset, global_work_size))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::Save(const int file_handle)
  {
   if(!CNeuronBaseOCL::Save(file_handle))
      return false;
   if(FileWriteInteger(file_handle, m_iInputs, INT_VALUE) < sizeof(m_iInputs))
      return false;
   if((m_cWeightsLSTM.GetIndex() >= 0 && !m_cWeightsLSTM.BufferRead()) || !m_cWeightsLSTM.Save(file_handle))
      return false;
   if((m_cFirstMomentumLSTM.GetIndex() >= 0 && !m_cFirstMomentumLSTM.BufferRead()) || !m_cFirstMomentumLSTM.Save(file_handle))
      return false;
   if((m_cSecondMomentumLSTM.GetIndex() >= 0 && !m_cSecondMomentumLSTM.BufferRead()) || !m_cSecondMomentumLSTM.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronLSTMOCL::Load(const int file_handle)
  {
   if(!CNeuronBaseOCL::Load(file_handle))
      return false;
   m_iInputs = FileReadInteger(file_handle);
//---
   m_cWeightsLSTM.BufferFree();
   if(!m_cWeightsLSTM.Load(file_handle) || !m_cWeightsLSTM.BufferCreate(OpenCL))
      return false;
//---
   m_cFirstMomentumLSTM.BufferFree();
   if(!m_cFirstMomentumLSTM.Load(file_handle) || !m_cFirstMomentumLSTM.BufferCreate(OpenCL))
      return false;
//---
   m_cSecondMomentumLSTM.BufferFree();
   if(!m_cSecondMomentumLSTM.Load(file_handle) || !m_cSecondMomentumLSTM.BufferCreate(OpenCL))
      return false;
//---
   if(m_iMemory >= 0)
      OpenCL.BufferFree(m_iMemory);
   m_iMemory = OpenCL.AddBuffer(sizeof(float) * 2 * Neurons(), CL_MEM_READ_WRITE);
   if(m_iMemory < 0)
      return false;
//---
   if(m_iConcatenated >= 0)
      OpenCL.BufferFree(m_iConcatenated);
   m_iConcatenated = OpenCL.AddBuffer(sizeof(float) * 4 * Neurons(), CL_MEM_READ_WRITE);
   if(m_iConcatenated < 0)
      return false;
//---
   if(m_iConcatenatedGradient >= 0)
      OpenCL.BufferFree(m_iConcatenatedGradient);
   m_iConcatenatedGradient = OpenCL.AddBuffer(sizeof(float) * 4 * Neurons(), CL_MEM_READ_WRITE);
   if(m_iConcatenatedGradient < 0)
      return false;
//---
   if(m_iHiddenState >= 0)
      OpenCL.BufferFree(m_iHiddenState);
   m_iHiddenState = OpenCL.AddBuffer(sizeof(float) * Neurons(), CL_MEM_READ_WRITE);
   if(m_iHiddenState < 0)
      return false;
//---
   if(m_iWeightsGradient >= 0)
      OpenCL.BufferFree(m_iWeightsGradient);
   m_iWeightsGradient = OpenCL.AddBuffer(sizeof(float) * m_cWeightsLSTM.Total(), CL_MEM_READ_WRITE);
   if(m_iWeightsGradient < 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef class_vae
#include "..\Unsupervised\AE\VAE.mqh"
#endif
//+------------------------------------------------------------------+
