
// simulatedAnnealing.cpp

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
#include "sa.hpp"
#include <string>
#include <fstream>
#include <iostream>

#include <signal.h>

namespace
{

  volatile int keyboardInterruptReceived = 0;

  void keyboardInterruptHandler(int sig)
  {
    keyboardInterruptReceived = 1;
  }

  void printUsage(std::ostream &out, const char *programName)
  {
    out << "Usage: " << programName << " OPTION...\n"
        << "Performs simulated annealing on a schedule.\n\n"
        << "  -s, --spec <file>           Specifies the specification file to use.\n"
        << "                              If - is specified, standard input is\n"
        << "                              used, which is the default.\n"
        << "  -t, --state <file>          Specifies the state file to use.\n"
        << "                              If - is specified, standard input is\n"
        << "                              used, which is the default.\n"
        << "  -o, --output <file>         Specifies the file into which the\n"
        << "                              final best state will be written.\n"
        << "                              If - is specified, standard output is\n"
        << "                              used, which is the default.\n"
        << "  -i, --initial <temperature> initial temperature\n"
        << "  -f, --final <temperature>   final temperature\n"
        << "  -c, --cooling <factor>      cooling factor\n"
        << "  -n, --iterations <number>   iterations per temperature\n"
        << "  -x, --multiplier <factor>   iteration multiplier\n"
        << "  -v, --verbose               enables verbose mode\n"
        << "  -h, --help                  Causes this help message to be printed\n";
    out << std::flush;
  }
}

int main(int argc, char **argv)
{
  using namespace cws;
  
  std::string specFile = "-", stateFile = "-", outputFile = "-";
  float initialTemperature = -1, finalTemperature = -1;
  float coolingFactor = -1;
  int iterationsPerTemperature = -1;
  float iterationMultiplier = -1;
  bool verbose = false;

  // Register the keyboard interrupt handler
  signal(SIGINT, &keyboardInterruptHandler);
  
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
    } else if (arg == "-o" || arg == "--output")
    {
      ++i;
      if (i < argc)
      {
        outputFile = argv[i];
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-i" || arg == "--initial")
    {
      ++i;
      if (i < argc)
      {
        float value = atof(argv[i]);
        if (value < 0)
        {
          std::cerr << "Invalid initial temperature: " << value << '\n';
          printUsage(std::cerr, argv[0]);
          return 1;
        }
        initialTemperature = value;
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-f" || arg == "--final")
    {
      ++i;
      if (i < argc)
      {
        float value = atof(argv[i]);
        if (value < 0)
        {
          std::cerr << "Invalid final temperature: " << value << '\n';
          printUsage(std::cerr, argv[0]);
          return 1;
        }
        finalTemperature = value;
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-c" || arg == "--cooling")
    {
      ++i;
      if (i < argc)
      {
        float value = atof(argv[i]);
        if (value <= 0 || value >= 1)
        {
          std::cerr << "Invalid cooling factor: " << value << '\n';
          printUsage(std::cerr, argv[0]);
          return 1;
        }
        coolingFactor = value;
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-x" || arg == "--multiplier")
    {
      ++i;
      if (i < argc)
      {
        float value = atof(argv[i]);
        if (value <= 0)
        {
          std::cerr << "Invalid iteration multiplier: " << value << '\n';
          printUsage(std::cerr, argv[0]);
          return 1;
        }
        iterationMultiplier = value;
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-n" || arg == "--iterations")
    {
      ++i;
      if (i < argc)
      {
        int value = atoi(argv[i]);
        if (value < 0)
        {
          std::cerr << "Invalid number of iterations: " << value << '\n';
          printUsage(std::cerr, argv[0]);
          return 1;
        }
        iterationsPerTemperature = value;
      } else
      {
        std::cerr << "Command-line argument expected after: "
                  << arg << '\n';
        printUsage(std::cerr, argv[0]);
        return 1;
      }
    } else if (arg == "-v" || arg == "--verbose")
    {
      verbose = true;
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

  if (initialTemperature < 0)
  {
    std::cerr << "The initial temperature must be specified.\n";
    printUsage(std::cerr, argv[0]);
    return 1;
  }

  if (finalTemperature < 0)
  {
    finalTemperature = 0;
  }

  if (iterationMultiplier < 0)
  {
    iterationMultiplier = 1.0f;
  }

  if (coolingFactor < 0)
  {
    std::cerr << "The cooling factor must be specified.\n";
    printUsage(std::cerr, argv[0]);
    return 1;
  }
  
  if (iterationsPerTemperature < 0)
  {
    std::cerr << "The number of iterations per temperature must be specified.\n";
    printUsage(std::cerr, argv[0]);
    return 1;
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

  SimulatedAnnealingAgent agent(spec, state);

  int prevImprovements = 0, prevChanges = 0;
  int currentIterationsPerTemperature = iterationsPerTemperature;

  for (float temperature = initialTemperature;
       temperature > finalTemperature;
       temperature *= coolingFactor,
         currentIterationsPerTemperature
         = (int)(currentIterationsPerTemperature
                 * iterationMultiplier))
  {
    agent.resetCurrent();
    for (int i = 0; i < currentIterationsPerTemperature; ++i)
    {
      if (keyboardInterruptReceived)
        break;
      agent.performIteration(temperature);
    }
    
    if (verbose)
    {
      std::clog << "(t = " << temperature << ", n = "
                << agent.iterationCount() << ") Cost: "
                << std::fixed << agent.bestCost()
                << "  Improvements: " << agent.improvementCount() - prevImprovements
                << "  Changes: " << agent.changeCount() - prevChanges
                << std::endl;
    }
    prevImprovements = agent.improvementCount();
    prevChanges = agent.changeCount();

    if (keyboardInterruptReceived)
      break;
  }

  if (outputFile == "-")
  {
    writeState(std::cout, agent.bestState());
    std::clog << "Wrote best state to standard output." << std::endl;
  } else
  {
    std::ofstream out(outputFile.c_str());
    writeState(out, agent.bestState());
    std::clog << "Wrote best state to: " << outputFile << std::endl;
  }

  return 0;
}
