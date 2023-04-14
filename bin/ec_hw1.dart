import 'dart:math';

import 'package:ec_hw1/ec_hw1.dart' as ec_hw1;

void main(List<String> arguments) {
  var primaryPopulation = getPrimaryPopulation(count: 10);
  for (var element in primaryPopulation) {
    element.setFitness =
        evaluationFunction(element) <= 0 ? 0 : evaluationFunction(element);
    print(element);
  }
  double sumFitness = calculateAllFitness(listIndividual: primaryPopulation);
  for (var element in primaryPopulation) {
    element.setProbabilityChoice = element.getFitness! / sumFitness;
  }

  List<double> sortedAscendingByProbability =
      primaryPopulation.map((e) => e.getProbabilityChoice!).toList()..sort();
  sortedAscendingByProbability = sortedAscendingByProbability.reversed.toList();
  for (var element in sortedAscendingByProbability) {
    print(element);
  }
  var selectedPatentsByRouletteWheel = <Individual>[];
  for (var i = 0; i < 10; i++) {
    double result = RouletteWheel(sortedAscendingByProbability).spin();
    //! detect which individual was selected by result
    var selected = primaryPopulation
        .firstWhere((element) => element.getProbabilityChoice == result);
    selectedPatentsByRouletteWheel.add(selected);
  }
  for (var i = 0; i < 10; i++) {
    int randomNumber = Random().nextInt(10);
    var firstParent = selectedPatentsByRouletteWheel[randomNumber];
    randomNumber = Random().nextInt(10);
    var secondParent = selectedPatentsByRouletteWheel[randomNumber];
    int crossoverPointNumber = Random().nextInt(6);
  }
}

// double sumFirstWithIndex(
//     {required int index, required List<double> sortedList}) {
//   double sum = 0;
//   for (var i = 0; i < index; i++) {
//     sum += sortedList[i];
//   }
//   return sum;
// }
class RouletteWheel {
  final List<double> numbers;

  RouletteWheel(this.numbers);

  double spin() {
    double randomNumber = Random().nextDouble() * 100;

    return numbers[randomNumber.floor()];
  }
}

class Individual {
  List<int> _binaryValueA;
  List<int> _binaryValueB;
  List<int> _binaryValueC;
  List<int> _binaryValueD;
  List<int> _binaryValueE;
  List<int> _binaryValueF;
  double? _fitness;
  double? _probabilityChoice;

  Individual({
    required List<int> binaryValueA,
    required List<int> binaryValueB,
    required List<int> binaryValueC,
    required List<int> binaryValueD,
    required List<int> binaryValueE,
    required List<int> binaryValueF,
  })  : _binaryValueA = binaryValueA,
        _binaryValueB = binaryValueB,
        _binaryValueC = binaryValueC,
        _binaryValueD = binaryValueD,
        _binaryValueE = binaryValueE,
        _binaryValueF = binaryValueF;

  List<int> get getBinaryValueA => _binaryValueA;
  set setBinaryValueA(List<int> binaryValue) => _binaryValueA = binaryValue;

  List<int> get getBinaryValueB => _binaryValueB;
  set setBinaryValueB(List<int> binaryValue) => _binaryValueB = binaryValue;

  List<int> get getBinaryValueC => _binaryValueC;
  set setBinaryValueC(List<int> binaryValue) => _binaryValueC = binaryValue;

  List<int> get getBinaryValueD => _binaryValueD;
  set setBinaryValueD(List<int> binaryValue) => _binaryValueD = binaryValue;

  List<int> get getBinaryValueE => _binaryValueE;
  set setBinaryValueE(List<int> binaryValue) => _binaryValueE = binaryValue;

  List<int> get getBinaryValueF => _binaryValueF;
  set setBinaryValueF(List<int> binaryValue) => _binaryValueF = binaryValue;

  double? get getFitness => _fitness;
  set setFitness(double? fitness) => _fitness = fitness;

  double? get getProbabilityChoice => _probabilityChoice;
  set setProbabilityChoice(double? probabilityChoice) =>
      _probabilityChoice = probabilityChoice;

  @override
  String toString() {
    return '[$_binaryValueA$_binaryValueB$_binaryValueC$_binaryValueD$_binaryValueE$_binaryValueF] _fitness: $_fitness)';
  }
}

double evaluationFunction(Individual individual) {
  var a = individual.getBinaryValueA.binaryToHex();
  var b = individual.getBinaryValueB.binaryToHex();
  var c = individual.getBinaryValueC.binaryToHex();
  var d = individual.getBinaryValueD.binaryToHex();
  var e = individual.getBinaryValueE.binaryToHex();
  var f = individual.getBinaryValueF.binaryToHex();
  var term1 = a * a;
  var term2 = (((a * c) - (e * d)) / (a + f)) * b;
  var term3 = (f * c) / e;
  return (term1 + term2 + term3);
}

List<Individual> getPrimaryPopulation({int count = 10}) {
  var individuals = <Individual>[];
  for (var i = 0; i < count; i++) {
    individuals.add(Individual(
        binaryValueA: generateRandomBinaryNumber(),
        binaryValueB: generateRandomBinaryNumber(),
        binaryValueC: generateRandomBinaryNumber(),
        binaryValueD: generateRandomBinaryNumber(),
        binaryValueE: generateRandomBinaryNumber(),
        binaryValueF: generateRandomBinaryNumber()));
  }
  return individuals;
}

extension on List<int> {
  int binaryToHex() {
    int power = 1;
    int hexNumber = 0;
    for (var i = length - 1; i >= 0; i--) {
      var temp = this[i] * power;
      hexNumber += temp;
      power *= 2;
    }
    return hexNumber;
  }
}

List<int> generateRandomBinaryNumber() {
  List<int> binaryNumber = [];
  int condition = 0;
  while (condition != 4) {
    condition++;
    if (Random().nextBool()) {
      binaryNumber.add(1);
    } else {
      binaryNumber.add(0);
    }
  }
  return binaryNumber;
}

double calculateAllFitness({required List<Individual> listIndividual}) {
  double sumFitness = 0;
  for (var element in listIndividual) {
    sumFitness += element.getFitness!;
  }
  return sumFitness;
}
