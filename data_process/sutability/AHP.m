function [Q]=AHP(B)
%QΪȨֵ��BΪ�ԱȾ���
%�����б����B
[n,m]=size(B);
%�б���������ȫһ����
for i=1:n
    for j=1:n
        if B(i,j)*B(j,i)~=1   
        fprintf('i=%d,j=%d,B(i,j)=%d,B(j,i)=%d\n',i,j,B(i,j),B(j,i))  
        end  
    end
end
%������ֵ��������,�ҵ��������ֵ��Ӧ����������
[V,D]=eig(B);
tz=max(D);
tzz=max(tz);
c1=find(D(1,:)==max(tz));
tzx=V(:,c1);%��������
%Ȩ
quan=zeros(n,1);
for i=1:n
quan(i,1)=tzx(i,1)/sum(tzx);
end
Q=quan;
%һ���Լ���
CI=(tzz-n)/(n-1);
RI=[0,0,0.58,0.9,1.12,1.24,1.32,1.41,1.45,1.49,1.52,1.54,1.56,1.58,1.59];
%�ж��Ƿ�ͨ��һ���Լ���
CR=CI/RI(1,n);
if CR>=0.1
   fprintf('û��ͨ��һ���Լ���\n');
else
  fprintf('ͨ��һ���Լ���\n');
end
 


