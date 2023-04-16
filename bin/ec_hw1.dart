import 'dart:convert';
import 'dart:math';

const countSelector =
    50; // this number is default for number of selecting parent and child
const numberFragmentChromosome = 6; // a,b,c,d,e,f

//! notice : dart lang work with call by refrence. if we want pass object as argument of function, we should create copy of object then pass that copy
void main(List<String> arguments) {
  var primaryPopulation = getPrimaryPopulation(count: countSelector);
  List<Individual> primaryPopulation2 = List.of(primaryPopulation);

  print('start RouletteWheel\n ');
  selectIndWithRouletteWheel(primaryPopulation2);
  print('\nstart SUS\n ');
  selectIndWithSUS(primaryPopulation);
}

class RouletteWheel {
  final List<Individual> individual;
  late List<Map<String, dynamic>> sortedAscendingByProbability;
  RouletteWheel(this.individual) {
    _setProbability();
    sortedAscendingByProbability = individual
        .map((e) => {'id': e.getId, 'possibility': e.getProbabilityChoice!})
        .toList()
      ..sort(
        (a, b) =>
            (a['possibility'] as double).compareTo(b['possibility'] as double),
      );
    // sortedAscendingByProbability =
    //     sortedAscendingByProbability.reversed.toList();
  }
  void _setProbability() {
    double sumFitness = calculateAllFitness(listIndividual: individual);
    for (var element in individual) {
      element.setProbabilityChoice = element.getFitness! / sumFitness;
    }
  }

  Individual spin() {
    double randomNumber = Random().nextDouble();
    Map<String, dynamic> item = _selectInd(randomNumber: randomNumber);
    return individual
        .firstWhere((element) => element.getId == (item['id'] as int));
  }

  Map<String, dynamic> _selectInd({required double randomNumber}) {
    for (var i = 0; i < sortedAscendingByProbability.length; i++) {
      if (_sumFirstUntilIndex(index: i) <= randomNumber &&
          randomNumber < _sumFirstUntilIndex(index: i + 1)) {
        return sortedAscendingByProbability[i];
      }
    }
    return {};
  }

  double _sumFirstUntilIndex({required int index}) {
    double sum = 0;
    for (var i = 0; i < index; i++) {
      sum += (sortedAscendingByProbability[i]['possibility'] as double);
    }
    return sum;
  }
}

class Individual {
  final int _id;
  final List<List<int>> _listFragment;
  double? _probabilityChoice;

  Individual(
      {required int id,
      required List<List<int>> listFragment,
      double? probabilityChoice})
      : _id = id,
        _listFragment = listFragment,
        _probabilityChoice = probabilityChoice;

  List<List<int>> get getListFragment => _listFragment;
  int get getId => _id;
  double? get getFitness => _evaluationFunction(this);

  double? get getProbabilityChoice => _probabilityChoice;
  set setProbabilityChoice(double? probabilityChoice) =>
      _probabilityChoice = probabilityChoice;

  double _evaluationFunction(Individual individual) {
    var a = individual._listFragment[0].binaryToDecimal();
    var b = individual._listFragment[1].binaryToDecimal();
    var c = individual._listFragment[2].binaryToDecimal();
    var d = individual._listFragment[3].binaryToDecimal();
    var e = individual._listFragment[4].binaryToDecimal();
    var f = individual._listFragment[5].binaryToDecimal();
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
    return '$_listFragment fitness: $getFitness)';
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'_id': _id});
    result.addAll({'_listFragment': _listFragment});
    if (_probabilityChoice != null) {
      result.addAll({'_probabilityChoice': _probabilityChoice});
    }

    return result;
  }

  factory Individual.fromMap(Map<String, dynamic> map) {
    return Individual(
      id: map['_id']?.toInt() ?? 0,
      listFragment: List<List<int>>.from(
          map['_listFragment']?.map((x) => List<int>.from(x))),
      probabilityChoice: map['_probabilityChoice']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Individual.fromJson(String source) =>
      Individual.fromMap(json.decode(source));
}

List<Individual> getPrimaryPopulation({int count = 10}) {
  var individuals = <Individual>[];
  for (var i = 0; i < count; i++) {
    individuals.add(Individual(
      id: i + 1,
      listFragment: List.generate(
          numberFragmentChromosome, (index) => generateRandomBinaryNumber()),
    ));
  }
  return individuals;
}

extension on List<int> {
  int binaryToDecimal() {
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

class BaseAlgorithm {
  void crossover(
      {required Individual firstParentArg,
      required Individual secondParentArg}) {
    int crossoverPointNumber = Random().nextInt(5) + 1;
    for (var i = crossoverPointNumber; i < numberFragmentChromosome; i++) {
      var temp = firstParentArg.getListFragment[i];
      firstParentArg.getListFragment[i] = secondParentArg.getListFragment[i];
      secondParentArg.getListFragment[i] = temp;
    }
  }
}

class SUS {
  final List<Individual> individual;
  late List<Map<String, dynamic>> sortedAscendingByProbability;
  SUS(this.individual) {
    _setProbability();
    sortedAscendingByProbability = individual
        .map((e) => {'id': e.getId, 'possibility': e.getProbabilityChoice!})
        .toList()
      ..sort(
        (a, b) =>
            (a['possibility'] as double).compareTo(b['possibility'] as double),
      );
    // sortedAscendingByProbability =
    //     sortedAscendingByProbability.reversed.toList();
  }
  void _setProbability() {
    double sumFitness = calculateAllFitness(listIndividual: individual);
    for (var element in individual) {
      element.setProbabilityChoice = element.getFitness! / sumFitness;
    }
  }

  List<Individual> spin({required int np}) {
    List<Individual> selectedInd = [];
    var distance = 1 / np;
    double randomNumber = Random().nextDouble() * distance;
    for (var i = 0; i < np; i++) {
      Map<String, dynamic> item = _selectInd(randomNumber: randomNumber);
      var ind = individual
          .firstWhere((element) => element.getId == (item['id'] as int));
      selectedInd.add(ind);
      randomNumber += distance;
    }
    return selectedInd;
  }

  Map<String, dynamic> _selectInd({required double randomNumber}) {
    for (var i = 0; i < sortedAscendingByProbability.length; i++) {
      if (_sumFirstUntilIndex(index: i) <= randomNumber &&
          randomNumber < _sumFirstUntilIndex(index: i + 1)) {
        return sortedAscendingByProbability[i];
      }
    }
    return {};
  }

  double _sumFirstUntilIndex({required int index}) {
    double sum = 0;
    for (var i = 0; i < index; i++) {
      sum += (sortedAscendingByProbability[i]['possibility'] as double);
    }
    return sum;
  }
}

void selectIndWithRouletteWheel(List<Individual> primaryPopulation) {
  List<Individual> remainingsIndividuals = primaryPopulation;
  var selectedParentsByRouletteWheel = <Individual>[];
  var individualsAfterXover = <Individual>[];
  // select parents with RouletteWheel method
  int numberRepetition = 0;
  while (numberRepetition != countSelector) {
    selectedParentsByRouletteWheel.clear();
    individualsAfterXover.clear();
    numberRepetition++;
    RouletteWheel rouletteWheel = RouletteWheel(remainingsIndividuals);
    for (var i = 0; i < countSelector; i++) {
      Individual selectedIndividual = rouletteWheel.spin();
      selectedParentsByRouletteWheel.add(selectedIndividual);
    }
    // select randomly two parents for cross over them and create new child (:
    for (var i = 0; i < countSelector; i++) {
      Individual firstParent = Individual.fromMap(
          selectedParentsByRouletteWheel[Random().nextInt(countSelector)]
              .toMap());
      Individual secondParent = Individual.fromMap(
          selectedParentsByRouletteWheel[Random().nextInt(countSelector)]
              .toMap());

      BaseAlgorithm().crossover(
          firstParentArg: firstParent, secondParentArg: secondParent);
      individualsAfterXover.addAll([firstParent, secondParent].toList());
    }
    remainingsIndividuals.clear();

    remainingsIndividuals.addAll(selectedParentsByRouletteWheel.toList());
    remainingsIndividuals.addAll(individualsAfterXover.toList());
    var sumP = 0.0;
    // var sumC = 0.0;
    for (var element in selectedParentsByRouletteWheel) {
      sumP += element.getFitness!;
    }
    print('$numberRepetition- sumP is $sumP');
  }
}

void selectIndWithSUS(List<Individual> primaryPopulation) {
  List<Individual> remainingsIndividuals = primaryPopulation;
  var selectedParentsByRouletteWheel = <Individual>[];
  var individualsAfterXover = <Individual>[];
  // select parents with RouletteWheel method
  int numberRepetition = 0;
  while (numberRepetition != countSelector) {
    selectedParentsByRouletteWheel.clear();
    individualsAfterXover.clear();
    numberRepetition++;
    SUS sus = SUS(remainingsIndividuals);
    sus.spin(np: countSelector).forEach((element) {
      selectedParentsByRouletteWheel.add(element);
    });
    // select randomly two parents for cross over them and create new child (:
    for (var i = 0; i < countSelector; i++) {
      Individual firstParent = Individual.fromMap(
          selectedParentsByRouletteWheel[Random().nextInt(countSelector)]
              .toMap());
      Individual secondParent = Individual.fromMap(
          selectedParentsByRouletteWheel[Random().nextInt(countSelector)]
              .toMap());

      BaseAlgorithm().crossover(
          firstParentArg: firstParent, secondParentArg: secondParent);
      individualsAfterXover.addAll([firstParent, secondParent].toList());
    }
    remainingsIndividuals.clear();

    remainingsIndividuals.addAll(selectedParentsByRouletteWheel.toList());
    remainingsIndividuals.addAll(individualsAfterXover.toList());
    var sumP = 0.0;
    // var sumC = 0.0;
    for (var element in selectedParentsByRouletteWheel) {
      sumP += element.getFitness!;
    }
    print('$numberRepetition- sumP is $sumP');
  }
}
