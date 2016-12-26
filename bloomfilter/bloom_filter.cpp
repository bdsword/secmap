/************************************************/
// Bloom Filter - main
//
//
//
/***********************************************/
#include <iostream>
#include <stdlib.h>
#include <vector> 
#include <cstring>
#include <cmath>
#include "bloom_filter.hpp"

using namespace std;

int main(int argc, char *argv[])
{
    int i; //loop
    unsigned int n=0; //size of all pattern bit vector
    unsigned int k=0; //number of hash functions
    int function_flag=0; //default is 0 means create, 1 means add, 2 means check
    string _k("-k");
    string _n("-n");
    string _o("-o");
    string _a("-a"); //for adding a new element
    string _c("-c"); //for checking element whether it's already in bloom filter 
    
	int isdigit_shift=0;

    bool option_ok=true;
    char* bloom_filter_name;
    char* file_name;
    bool file_exist_flag=true;
    //parse inputs
    if((argc&0x01)==0||argc>7||argc<3){
        cout<<"ERROR: Wrong Input!"<<endl;
    }
    else{
         for(i=1;i<argc;i++){
             if(_k.compare(argv[i])==0){// -k number_of_hash_functions
                 char* str=argv[++i];
                 isdigit_shift=isnum(str);
                 if(isdigit_shift>=0){ k=(unsigned int)atoi(str)*(0x01<<isdigit_shift); }
                 else{ break; } 
             }
             else if(_n.compare(argv[i])==0){// -n bytes
                 char* str=argv[++i];
                 isdigit_shift=isnum(str);
                 if(isdigit_shift>=0){ n=(unsigned int)atoi(str)*(0x01<<isdigit_shift); }
                 else{ break; }
             }
             else if(_o.compare(argv[i])==0){// -o bloom_filter
                  bloom_filter_name=argv[++i];
				  if(file_exist_flag&&function_flag!=0){
					  file_exist_flag=fexists(bloom_filter_name);
				  }
             }
             else if(_a.compare(argv[i])==0){ // -a file_we_want_to_add
                  file_name=argv[++i];
                  if(file_exist_flag){
					  file_exist_flag=fexists(file_name);
				  }
                  function_flag=1;//set add flag
             }
             else if(_c.compare(argv[i])==0){ // -c file_we_want_to_check
                  file_name=argv[++i];
                  if(file_exist_flag){
					  file_exist_flag=fexists(file_name);
				  }
                  function_flag=2;//set check flag
             }
             else{
                  cout<<"Error: "<<argv[i]<<" is not the one of options"<<endl;
                  option_ok=false;
                  break;
             }
         }
         //according function flag to chose function we want
         if(isdigit_shift>=0&&file_exist_flag==true&&option_ok==true){
             if(function_flag==0){
                  create_bloom_filter(bloom_filter_name,n,k);
             }
			 else if(function_flag==1){
				  add_bloom_filter(bloom_filter_name,file_name);
			 }
             else if(function_flag==2){
                  check_bloom_filter(bloom_filter_name,file_name);
			 }
		 }
             
	}
	return 1;
}
