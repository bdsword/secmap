#include "bloom_filter_parse_function.hpp"
#include "hash_functions.hpp"
#include <fstream>
#include <iostream>
#include <cstring>
using namespace std;


void create_bloom_filter(char *bname, unsigned int n, unsigned int k)
{    // k - number of hash_functions
	 ofstream bf(bname,ofstream::binary);
     int i;
     unsigned int bit_vector_size=n/4; //every 4 byte => 1 integer
     if( (n-(bit_vector_size*4))!=0) bit_vector_size++; 
     vector<unsigned int> bit_vector(bit_vector_size);
	 
	 bf.write((char*)&k,sizeof(k));
     bf.write((char*)&n,sizeof(n));
	 
     for(i=0;i<bit_vector_size;i++){
         bit_vector[i]=0;
         bf.write((char*)&bit_vector[i],sizeof(bit_vector[i]));
     }
     bf.close();
}

void add_bloom_filter(char *bname, char *fname)
{
     fstream bf(bname,fstream::binary|fstream::in|fstream::out); 
     //ofstream bf2(bname,ofstream::binary);
	 unsigned int n;
	 unsigned int k;
     unsigned int bit_vector;
     
     
     int i=0; 
	 unsigned int hashValue;
	 string buf,line;
	 
     //read n,k 
	 bf.read((char*)&k,4);
	 bf.read((char*)&n,4);
     
     
	 //transfer file into string
	 ifstream in(fname);
	 while(getline(in,line)){
         buf+=line;
     }
     //do hash
     //according hash value to load bit vector
	 for(i=1;i<=k;i++){
		 hashValue=HashFunc(buf,i,n);
		 int m2=hashValue/32;
		 int m3=hashValue%32;
		 unsigned int powm3=(unsigned int)(2<<m3);
		 
		 
		 bf.seekg(sizeof(unsigned int)*(2+m2));
		 bf.read((char*)&bit_vector,sizeof(unsigned int));
		 
		 bit_vector=bit_vector|powm3;
		 
		 bf.seekp(sizeof(unsigned int)*(2+m2));
		 bf.write((char*)&bit_vector,sizeof(unsigned int));
	 }
	 
     bf.close();
	 
}

void check_bloom_filter(char *bname, char * fname)
{
     //string buf_k,buf_n,buf_t;
     ifstream bf(bname,ifstream::binary); 
	 unsigned int n;
	 unsigned int k;
	 unsigned int bit_vector;
     bool match_or_not=true;
	 
     int i=0; 
	 unsigned int hashValue;
	 string buf,line;
     //read n,k 
	 bf.read((char*)&k,4);
	 bf.read((char*)&n,4);
     
     //transfer file into string
     ifstream in(fname);
	 while(getline(in,line)){
         buf+=line;
     }
     
     //hash
     //according hash value to load bit vector
	 for(i=1;i<=k;i++){
		 hashValue=HashFunc(buf,i,n);
		 int m2=hashValue/32;
		 int m3=hashValue%32;
		 unsigned int powm3=(unsigned int)(2<<m3);
		 
		 bf.seekg(sizeof(unsigned int)*(2+m2));
		 bf.read((char*)&bit_vector,sizeof(unsigned int));
		 //check whether it exist or not
		 if((bit_vector&powm3)!=powm3){
			 match_or_not=false;
			 break;
		 }
	 }
     bf.close();
	 if(match_or_not)
		 cout<<fname<<": YES!"<<endl;
	 else
		 cout<<fname<<": NO!"<<endl;
	 
	 
}
