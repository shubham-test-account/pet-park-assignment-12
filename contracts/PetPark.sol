//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract PetPark {
    address public owner;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Adopter {
        uint8 age;
        Gender gender;
        AnimalType petAdopted;
        bool isInitialised;
    }

    mapping(AnimalType => uint) public animalCounts;
    mapping(address => Adopter) adopters;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    event Added(AnimalType animalType, uint howMany);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        owner = msg.sender;
    }

    function add(AnimalType _animalType, uint _howMany) external onlyOwner {
        require(_animalType != AnimalType.None, "Invalid animal");

        animalCounts[_animalType] += _howMany;
        emit Added(_animalType, _howMany);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) external {
        require(_age > 0, "Invalid Age");
        require(_animalType != AnimalType.None, "Invalid animal type");
        require(animalCounts[_animalType] > 0, "Selected animal not available");

        Adopter memory currentAdopter = adopters[msg.sender];

        if (currentAdopter.isInitialised) {
            require(currentAdopter.age == _age, "Invalid Age");
            require(currentAdopter.gender == _gender, "Invalid Gender");

            require(currentAdopter.petAdopted == AnimalType.None, "Already adopted a pet");
        }
        
        if (_gender == Gender.Male) {
            require(_animalType == AnimalType.Fish || _animalType == AnimalType.Dog,
            "Invalid animal for men");
        }
        else {
            if (_age < 40) {
                require(_animalType != AnimalType.Cat, "Invalid animal for women under 40");
            }
        }

        adopters[msg.sender] = Adopter(_age, _gender, _animalType, true);
        animalCounts[_animalType] -= 1;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() external {
        Adopter memory currentAdopter = adopters[msg.sender];

        require(currentAdopter.isInitialised, "No borrowed pets");
        require(currentAdopter.petAdopted != AnimalType.None, "No borrowed pets");

        animalCounts[currentAdopter.petAdopted] += 1;
        adopters[msg.sender].petAdopted = AnimalType.None;

        emit Returned(currentAdopter.petAdopted);
    }

}
