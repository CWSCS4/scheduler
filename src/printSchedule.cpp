
// printSchedule.cpp

// Copyright 2004 Jeremy Bertram Maitin-Shepard.

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License Version
// 2 as published by the Free Software Foundation.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA

#include "state.hpp"
#include "specification.hpp"
#include "io.hpp"
#include "diagnostics.hpp"
#include <string>
#include <fstream>
#include <iostream>

namespace
{
  void printUsage(std::ostream &out, const char *programName)
  {
    out << "Usage: " << programName << " OPTION...\n"
        << "Prints a schedule.\n\n"
        << "  -s, --spec <file>           Specifies the specification file to use.\n"
        << "                              If - is specified, standard input is\n"
        << "                              used, which is the default.\n"
        << "  -t, --state <file>          Specifies the state file to use.\n"
        << "                              If - is specified, standard input is\n"
        << "                              used, which is the default.\n"
        << "  -h, --help                  Causes this help message to be printed\n";
    out << std::flush;
  }
}

int main(int argc, char **argv)
{
  using namespace cws;
  
  std::string specFile = "-", stateFile = "-";
  
  // Parse arguments

  for (int i = 1; i < argc; ++i)
  {
    std::string arg = argv[i];
    if (arg == "-s" || arg == "--spec")
    {
      ++i;
      if (i < argc)
      {
        specFile = argv[i];
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-t" || arg == "--state")
    {
      ++i;
      if (i < argc)
      {
        stateFile = argv[i];
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-h" || arg == "--help")
    {
      printUsage(std::cout, argv[0]);
      return 0;
    } else {
      std::cerr << "Invalid command-line argument: " << arg << '\n';
      printUsage(std::cerr, argv[0]);
      return 1;
    }
  }
  
  Specification spec;

  if (specFile == "-")
  {
    if (!readSpecification(std::cin, spec))
    {
      std::cerr << "Error reading specification from stdin"
                << std::endl;
      return 1;
    }
  } else
  {
    std::ifstream in(specFile.c_str());
    if (!readSpecification(in, spec))
    {
      std::cerr << "Error reading specification from: "
                << specFile
                << std::endl;
      return 1;
    }
  }

  State state;

  if (stateFile == "-")
  {
    if (!readState(std::cin, state))
    {
      std::cerr << "Error reading state from stdin"
                << std::endl;
      return 1;
    }
  } else
  {
    std::ifstream in(stateFile.c_str());
    if (!readState(in, state))
    {
      std::cerr << "Error reading state from: "
                << stateFile
                << std::endl;
      return 1;
    }
  }

  if (state.participantCount() != spec.participantCount()
      || state.slotCount() != spec.slotCount())
  {
    std::cerr << "The state and specification are not compatible."
              << std::endl;
  }

  printSchedule(std::cout, state, spec);

  return 0;
}
