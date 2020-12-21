#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <map>

using namespace std;

class Allergen {
public:
    set<string> candidates;

    string name;
    Allergen(string name): name(name) {
    }
};

class Food {
public:
    set<string> ingredients;
    set<Allergen *> allergens;

    Food(set<string> ingredients, set<Allergen *> allergens): ingredients(ingredients), allergens(allergens) {
    }
};

class Input {
public:
    set<string> ingredients;
    map<string, Allergen> allergens;

    vector<Food> foods;

    void operator<<(istream &stream) {
        string line;

        while (getline(stream, line)) {
            set<Allergen *> foodAllergens;
            set<string> foodIngredients;

            auto start = line.begin();
            for (auto it = start; it != line.end(); ++it) {
                if (*it == ' ') {
                    if (start == it + 1) {
                        continue;
                    }

                    // ingredient
                    string token(start, it);
                    foodIngredients.insert(token);
                    ingredients.insert(token);
                    start = it + 1;
                } else if (*it == '(') {
                    it += 10;
                    start = it;
                } else if (*it == ',' || *it == ')') {
                    string token(start, it);
                    auto al = allergens.find(token);
                    if (al == allergens.end()) {
                        Allergen a(token);

                        for (auto & i : foodIngredients) {
                            a.candidates.insert(i);
                        }

                        al = allergens.insert(pair<string, Allergen>(token, a)).first;
                    } else {
                        set<string> cand(al->second.candidates);

                        for (auto & i : foodIngredients) {
                            cand.erase(i);
                        }

                        for (auto & i : cand) {
                            al->second.candidates.erase(i);
                        }
                    }

                    foodAllergens.insert( & (al->second));

                    if (*it == ')') { // end of allergens
                        break;
                    }

                    ++it; // skip space
                    start = it + 1;
                }
            }

            Food f(foodIngredients, foodAllergens);
            foods.push_back(f);
        }

//        for (auto &i : ingredients) {
//            cout << i << " ";
//        }
//        cout << endl;

//        cout << allergens.size() << endl;

        set<string> unsafe;

        bool erased;
        do {
            erased = false;
            for (auto & a : allergens) {
                auto & cand = a.second.candidates;
                if (cand.size() == 1) {
                    auto & singleton = *cand.begin();
                    unsafe.insert(singleton);

                    for (auto & a2 : allergens) {
                        auto & cand2 = a2.second.candidates;
                        if (cand2.size() == 1) {
                            continue;
                        } else {
                            if (cand2.erase(singleton) > 0) {
                                erased = true;
                            }
                        }
                    }
                }
            }
        } while(erased);

        int cnt = 0;
        for (auto & f: foods) {
            for (auto & i : f.ingredients) {
                if (unsafe.find(i) == unsafe.end()) {
                    cnt++;
                }
            }
        }
        cout << "Safe: " << cnt << endl;

//        cout << "Unsafe: " << unsafe.size() << endl;

        cout << "Dangerous: ";
        bool first = true;
        for (auto & a : allergens) {
            if (!first) {
                cout << ",";
            } else {
                first = false;
            }
            cout << *(a.second.candidates.begin());
        }
        cout << endl;
    }
};

Input readFile(char * fileName) {
    ifstream file (fileName);
    Input input;
    input << file;
    return input;
}

int main (int argc, char *argv[]) {
    if (argc != 2) {
        cerr << "Provide an argument";
        exit(1);
    }

    char * fileName = argv[1];

    readFile(fileName);

    return 0;
}
