#include "SimpleShells/include/SimpleShellsAgentWorldModel.h"

#include "World/World.h"
#include <numeric>

#include <iostream>

SimpleShellsAgentWorldModel::SimpleShellsAgentWorldModel() {
	setRobotLED_status(true);
	_action = ACTION_ACTIVATE;
	_timeLived = 1;
	_speedPenalty = 1.0;
	_specialisation = 0.0;
	_nrBoosts = 0;
	_energyPuckId = -1;
	_energyBoost = 0.05;
	_fixedBoost = false;
	_maxNrBoosts = 10;
	_excludeEnergyPucks = true;
	_useSpecialiser = false;
	_spawnProtection = false;
	_stealFixed = true;
	_spawnProtectDuration = 100;
	_stealAmount = 10;
	_specialiserLifeCap = 0;
	_stealMargin = 10;


	// For backward compatibility, we might check gSpecialisation as bool and as double; bool false-> 0.0, true->1.0
	///bool temp(false);
	///if (gProperties.checkAndGetPropertyValue("gSpecialisation", &temp, false)) {
	///_specialisation = temp ? 1.0 : 0.0;
	///} else {

	gProperties.checkAndGetPropertyValue("gSpecialisation", &_specialisation, false);
	gProperties.checkAndGetPropertyValue("energyBoost", &_energyBoost, false);
	gProperties.checkAndGetPropertyValue("fixedBoost", &_fixedBoost, false);
	gProperties.checkAndGetPropertyValue("maxNrBoost", &_maxNrBoosts, false);
	gProperties.checkAndGetPropertyValue("energyPuckId", &_energyPuckId, false);
	gProperties.checkAndGetPropertyValue("excludeEnergyPucks", &_excludeEnergyPucks, false);
	
	gProperties.checkAndGetPropertyValue("gUseSpecialiser", &_useSpecialiser, false);
	gProperties.checkAndGetPropertyValue("gSpawnProtection", &_spawnProtection, false);
	gProperties.checkAndGetPropertyValue("gStealFixed", &_stealFixed, false);
	gProperties.checkAndGetPropertyValue("gSpawnProtectDuration", &_spawnProtectDuration, false);
	gProperties.checkAndGetPropertyValue("gStealAmount", &_stealAmount, false);
	gProperties.checkAndGetPropertyValue("gStealMargin", &_stealMargin, false);
	gProperties.checkAndGetPropertyValue("gSpecialiserLifeCap", &_specialiserLifeCap, false);
}

SimpleShellsAgentWorldModel::~SimpleShellsAgentWorldModel() {
}

void SimpleShellsAgentWorldModel::dumpGenePoolStats() const {
	std::vector<Genome>::const_reverse_iterator itGenome;
	double totalFitness = .0;
	gLogFile << "EggHatched: (" << gWorld->getIterations() << "; " << _xReal << "; " << _yReal << "); [";
	for (itGenome = _genePool.rbegin(); itGenome < _genePool.rend(); itGenome++) {
		if (itGenome != _genePool.rbegin()) {
			gLogFile << ", ";
		}
		gLogFile << "[";
		for (int i = 0; i < gPuckColors; i++) {
			gLogFile << itGenome->pucks[i] << ", ";
		}
		gLogFile << itGenome->fitness << ", " << itGenome->id << "]";
		totalFitness += itGenome->fitness;
	}
	gLogFile << "]; Winner: " << _winnerId << std::endl;
}

void SimpleShellsAgentWorldModel::setSpeedPenalty() {

	_speedPenalty = 1.0;
	if (_puckCounters && ! _puckCounters->empty())
	{
		double max = (double) *(std::max_element(_puckCounters->begin(), _puckCounters->end()));
		double sum = (double) std::accumulate(_puckCounters->begin(), _puckCounters->end(), 0);
		double x = (sum == 0.0) ? 1.0 : (max/sum); // x is the specialisation level

		_speedPenalty = pow(x, _specialisation);
		//        std::cout << "specialisation: " << x << " (" << max << '/' << sum << "); speed penalty: " << _speedPenalty << ", penalty level: " << _specialisation << '\n';
	}
}

void SimpleShellsAgentWorldModel::collectPuck(int g) {
	if ((double) std::accumulate(_puckCounters->begin(), _puckCounters->end(), 0) == 0) {
		// std::cout << "FIRST PUCK AT AGE: " << this->_timeLived << std::endl;
	}
	if (g == _energyPuckId) {
		if (_nrBoosts < _maxNrBoosts) {
			// add lifetime
			std::cout << "energy puck " << _nrBoosts +1 << " lifetime from " << _lifetime[PHASE_GATHERING];

			int boost = 0;
			if (_fixedBoost)
				boost = int(double(_maxLifetime) * _energyBoost);
			else
				boost = int(double(_lifetime[PHASE_GATHERING]) * _energyBoost);
			_lifetime[PHASE_GATHERING] += boost;
			std::cout << " to " << _lifetime[PHASE_GATHERING] << '\n';
		}
		_nrBoosts++;
	} 

	if (g != _energyPuckId  || !_excludeEnergyPucks) {
		_puckCounters->at(g)++;
		setSpeedPenalty();
	}
}

void SimpleShellsAgentWorldModel::stealLife(RobotAgentWorldModel* other_wm) {

	if (_useSpecialiser) {
		SimpleShellsAgentWorldModel* otherWm = static_cast<SimpleShellsAgentWorldModel*>(other_wm);
		if (_spawnProtection) {
			if (otherWm->_timeLived <= _spawnProtectDuration) {
				return;
			}
		}

		if (calcScoreFrom_wm(this) * (1 + _stealMargin / 100) > calcScoreFrom_wm(other_wm)) { // if I am better
			int tmpLife = _lifetime[PHASE_GATHERING];

			_lifetime[PHASE_GATHERING] += std::min(otherWm->_lifetime[PHASE_GATHERING] - 1, _stealAmount);
			
			// will output in format: [lifestolen] iterations thisId thisScore otherId otherScore amountStolen amountAfter
			std::cout << "[lifestolen]"    << ' ' << this->_world->getIterations() << ' ';
			std::cout << this->_agentId    << ' ' << calcScoreFrom_wm(this) << ' '; 
			std::cout << otherWm->_agentId << ' ' << calcScoreFrom_wm(other_wm) << ' ';


			if (_specialiserLifeCap > 0 ){
				_lifetime[PHASE_GATHERING] = std::min(_lifetime[PHASE_GATHERING], _specialiserLifeCap);
			}

			std::cout << _lifetime[PHASE_GATHERING]  - tmpLife << ' ' << _lifetime[PHASE_GATHERING] << std::endl;

		} else if (calcScoreFrom_wm(this) < calcScoreFrom_wm(other_wm) * (1 + _stealMargin / 100) ){ // else if the other is better
			_lifetime[PHASE_GATHERING] -= std::min(_lifetime[PHASE_GATHERING] - 1, _stealAmount);
		} 

	}
	
}

double SimpleShellsAgentWorldModel::calcScoreFrom_wm(RobotAgentWorldModel* some_wm) {
	SimpleShellsAgentWorldModel* wm = static_cast<SimpleShellsAgentWorldModel*>(some_wm);
	double pucks = (double) std::accumulate(wm->_puckCounters->begin(), wm->_puckCounters->end(), 0);

	return (pucks/wm->_timeLived) * 1000;
}

void SimpleShellsAgentWorldModel::reset(int maxLifetime[]) {
	// Somewhat random lifetime to prevent synchronised life cycles
	_lifetime[PHASE_GATHERING] = _maxLifetime = maxLifetime[PHASE_GATHERING] * (ranf() * 0.25 + 0.75);
	_lifetime[PHASE_MATING] = maxLifetime[PHASE_MATING];

	// Remove all gathered genomes from the gene pool
	_genePool.clear();

	_puckCounters->assign(gPuckColors, 0);

	_nrBoosts = 0;
	_speedPenalty = 1.0;

	_timeLived = 1;

}
