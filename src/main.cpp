// system headers
#include <elf.h>
#include <fstream>
#include <iostream>
#include <unordered_map>
#include <string>

// library headers
#include <argagg/argagg.hpp>

// this maps ELF machine header types to AppImage style strings
static const std::unordered_map<int, std::string> Archs{
    {EM_386, "i686"},
    {EM_X86_64, "x86_64"},
    {EM_ARM, "armhf"},
    {EM_AARCH64, "aarch64"},
};

int main(int argc, char** argv) {
    argagg::parser argparser {{
        {
            "help",
            {"-h", "--help"},
            "shows this help message",
            0
        }
    }};

    argagg::parser_results args;

    try {
        args = argparser.parse(argc, argv);
    } catch (const std::exception& e) {
        std::cerr << e.what() << '\n';
        return EXIT_FAILURE;
    }

    if (args["help"] || args.pos.size() <= 0) {
        std::cerr << argv[0] << " [options] <file>" << std::endl
                  << std::endl
                  << "Read ELF header of binary <file> and generate AppImage-style architecture name" << std::endl
                  << std::endl
                  << argparser;
        return EXIT_SUCCESS;
    }

    const std::string filePath = args.pos[0];

    // we can just use the 64-bit variant of the header struct to parse the first few fields
    // the fields are organized the same way in both 32-bit and 64-bit binaries
    // first, we need to read the right amount of bytes from the file
    Elf64_Ehdr ehdr;

    {
        std::ifstream ifs(filePath);

        if (!ifs) {
            std::cerr << "failed to open file " << filePath << std::endl;
            return EXIT_FAILURE;
        }

        ifs.read(reinterpret_cast<char*>(&ehdr), sizeof(Elf64_Ehdr));

        if (!ifs || ifs.gcount() != sizeof(Elf64_Ehdr)) {
            std::cerr << "failed to read from file " << filePath << std::endl;
            return EXIT_FAILURE;
        }
    }

    try {
        std::cout << Archs.at(ehdr.e_machine) << std::endl;
    } catch (const std::out_of_range&) {
        std::cerr << "could not find suitable description for architecture identifier " << ehdr.e_machine << std::endl
                  << "you can check elf.h's EM_* identifiers for more information" << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
