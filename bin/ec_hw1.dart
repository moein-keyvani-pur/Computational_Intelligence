import 'dart:math';

import 'package:ec_hw1/ec_hw1.dart' as ec_hw1;

void main(List<String> arguments) {
  var primaryPopulation = getPrimaryPopulation(count: 10);

  double sumFitness = calculateAllFitness(listIndividual: primaryPopulation);
  for (var element in primaryPopulation) {
    element.setProbabilityChoice = element.getFitness! / sumFitness;
  }

  var selectedPatentsByRouletteWheel = <Individual>[];
  for (var i = 0; i < 10; i++) {
    Individual selectedIndividual = RouletteWheel(primaryPopulation).spin();

    selectedPatentsByRouletteWheel.add(selectedIndividual);
  }
  crossover();
}

class RouletteWheel {
  final List<Individual> individual;
  late List<Map<String, dynamic>> sortedAscendingByProbability;
  RouletteWheel(this.individual) {
    sortedAscendingByProbability = individual
        .map((e) => {'id': e.getId, 'possibility': e.getProbabilityChoice!})
        .toList()
      ..sort(
        (a, b) =>
            (a['possibility'] as double).compareTo(b['possibility'] as double),
      );
    sortedAscendingByProbability =
        sortedAscendingByProbability.reversed.toList();
    for (var element in sortedAscendingByProbability) {
      print(element);
    }
  }

  Individual spin() {
    double randomNumber = Random().nextDouble();
    Map<String, dynamic> item = _ghaffari(randomNumber: randomNumber);
    return individual
        .firstWhere((element) => element.getId == (item['id'] as int));
  }

  double _sumFirstUntilIndex({required int index}) {
    double sum = 0;
    for (var i = 0; i < index; i++) {
      sum += (sortedAscendingByProbability[i]['possibility'] as double);
    }
    return sum;
  }

  Map<String, dynamic> _ghaffari({required double randomNumber}) {
    for (var i = 0; i < sortedAscendingByProbability.length; i++) {
      if (_sumFirstUntilIndex(index: i) <= randomNumber &&
          randomNumber < _sumFirstUntilIndex(index: i + 1)) {
        return sortedAscendingByProbability[i];
      }
    }
    return {};
  }
}

class Individual {
  final int _id;
  List<int> _binaryValueA;
  List<int> _binaryValueB;
  List<int> _binaryValueC;
  List<int> _binaryValueD;
  List<int> _binaryValueE;
  List<int> _binaryValueF;
  double? _fitness;
  double? _probabilityChoice;

  Individual({
    required int id,
    required List<int> binaryValueA,
    required List<int> binaryValueB,
    required List<int> binaryValueC,
    required List<int> binaryValueD,
    required List<int> binaryValueE,
    required List<int> binaryValueF,
  })  : _id = id,
        _binaryValueA = binaryValueA,
        _binaryValueB = binaryValueB,
        _binaryValueC = binaryValueC,
        _binaryValueD = binaryValueD,
        _binaryValueE = binaryValueE,
        _binaryValueF = binaryValueF;

  int get getId => _id;
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

  double? get getFitness => _evaluationFunction(this);

  double? get getProbabilityChoice => _probabilityChoice;
  set setProbabilityChoice(double? probabilityChoice) =>
      _probabilityChoice = probabilityChoice;

  double _evaluationFunction(Individual individual) {
    var a = individual.getBinaryValueA.binaryToHex();
    var b = individual.getBinaryValueB.binaryToHex();
    var c = individual.getBinaryValueC.binaryToHex();
    var d = individual.getBinaryValueD.binaryToHex();
    var e = individual.getBinaryValueE.binaryToHex();
    var f = individual.getBinaryValueF.binaryToHex();
    var term1 = a * a;
    var term2 = 0.0;
    if (a + f != 0) {
      term2 = (((a * c) - (e * d)) / (a + f)) * b;
    }
    var term3 = 0.0;
    if (e != 0) {
      term3 = (f * c) / e;
    }
    var result = term1 + term2 + term3;
    return result <= 0 ? 0 : result;
  }

  @override
  String toString() {
    return '[$_binaryValueA$_binaryValueB$_binaryValueC$_binaryValueD$_binaryValueE$_binaryValueF] _fitness: $_fitness)';
  }
}

List<Individual> getPrimaryPopulation({int count = 10}) {
  var individuals = <Individual>[];
  for (var i = 0; i < count; i++) {
    individuals.add(Individual(
        id: i + 1,
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

void crossover() {
  // for (var i = 0; i < 10; i++) {
  //   int randomNumber = Random().nextInt(10);
  //   var firstParent = selectedPatentsByRouletteWheel[randomNumber];
  //   randomNumber = Random().nextInt(10);
  //   var secondParent = selectedPatentsByRouletteWheel[randomNumber];
  //   int crossoverPointNumber = Random().nextInt(6);
  // }
}
