#include <iostream>
#include <fstream>
#include <cstring>

using namespace std;

int isnum(char* s){
    int isdigit_flag=0;
    for(unsigned int j=0;j<strlen(s);j++){
         if(!isdigit(s[j])) {
             if(j==(strlen(s)-1)&&(s[j]=='k'||s[j]=='K')){
                 isdigit_flag=10;
             }
             else if(j==(strlen(s)-1)&&(s[j]=='m'||s[j]=='M')){
                  isdigit_flag=20;
             }
             else if(j==(strlen(s)-1)&&(s[j]=='g'||s[j]=='G')){
                  isdigit_flag=30;
             }
             else{
                  isdigit_flag=-1;
                  cout<<"ERROR:"<<s<<" is not a valid number."<<endl;
                  break;
                  }
         }
     }
     return isdigit_flag;
}

bool fexists(const char *filename)
{
    ifstream ifile(filename);
	if(ifile==false){
		cout<<"Error: "<<filename<<" is not exist."<<endl;
	}
    return ifile;
}
