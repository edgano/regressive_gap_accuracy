#include <iostream>
#include <fstream>
#include <algorithm>

int main(int argc, char **argv) {
    char gap[] = "-";

    if (argc < 2) {
        std::cerr << " Wrong format: " << argv[0] << " [infile] " << std::endl;
        return -1;
    }

    std::ifstream input(argv[1]);
    if (!input.good()) {
        std::cerr << "Error opening: " << argv[1] << " . You have failed." << std::endl;
        return -1;
    }
    std::string line, id, DNA_sequence;
    size_t n = 0;
    size_t gap_global = 0;
    size_t number_seq = 0;
    // Don't loop on good(), it doesn't allow for EOF!!

//    while (std::getline(input, line).good()) {
    while (std::getline(input, line)) {

        // line may be empty so you *must* ignore blank lines
        // or you have a crash waiting to happen with line[0]
        if(line.empty())
            continue;

        if (line[0] == '>') {
            
            // output previous line before overwriting id
            // but ONLY if id actually contains something
            if(!id.empty()){
                std::cout << id << " : " << DNA_sequence << std::endl;
                n = std::count(DNA_sequence.begin(), DNA_sequence.end(), gap[0]);
                number_seq+=1;

                std::cout <<" Number of Gaps " << n << "  --  "<<number_seq<< std::endl;

                gap_global +=n;
                n=0;
            }
            id = line.substr(1);
            DNA_sequence.clear();
        }
        else {//  if (line[0] != '>'){ // not needed because implicit
            DNA_sequence += line;
        }
    }

    // output final entry
    // but ONLY if id actually contains something
    if(!id.empty()){
        std::cout << id << " : " << DNA_sequence << std::endl;
        n = std::count(DNA_sequence.begin(), DNA_sequence.end(), gap[0]);
        number_seq+=1;
        std::cout <<" Number of Gaps " << n << "  --  "<<number_seq<< std::endl;

        gap_global +=n;
    
        std::cout <<"\n** ** TOTAL of Gaps " << gap_global << std::endl;
        std::cout <<"** ** TOTAL of Sequences " << number_seq << std::endl;
        std::cout <<"** ** AVG Gaps " << (float) gap_global/number_seq << std::endl;

        
    }

}
// g++ script.cpp
// ./a.out /home/edgar/CBCRG/regressive_gap_accuracy/data/test/seatoxin.dpa_1000.CLUSTALO.with.CLUSTALO.tree.aln