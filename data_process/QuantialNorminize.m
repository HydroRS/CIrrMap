function [ output_args ] =QuantialNorminize( input_args )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
input_args=input_args(:);

q5=prctile(input_args,5);

q95=prctile(input_args,95);

input_args(input_args<q5)=q5;

input_args(input_args>q95)=q95;


output_args=(input_args-q5)./(q95-q5);

end

