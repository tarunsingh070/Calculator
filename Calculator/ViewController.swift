/*
 * File name : ViewController.swift
 * Author: Tarun Singh
 * Date: September 23, 2017
 * Student ID: 300967393
 * Description: ViewController class for the calculator. 
 * Version: 0.2 - Added basic operations functionality.
 * Copyright © 2017 Tarun Singh. All rights reserved.
 */

import UIKit

class ViewController: UIViewController {
    
    // Operators with precedence
    let DIVISION_OPERATOR = 4
    let MULTIPLICATION_OPERATOR = 3
    let ADDITION_OPERATOR = 2
    let SUBTRACTION_OPERATOR = 1
    
    var isInInitialState = true
    var wasLastButtonClickedAnOperator = false
    
    var currentOperator : Int = -1
    var currentOperand : String = "0"
    
    var operands = [String]()
    var operators = [String]()
    
    @IBOutlet weak var resultDisplayField: RoundLabel!
    @IBOutlet weak var clearButton: RoundButton!
    
    @IBAction func onNumberClicked(_ sender: RoundButton) {
        
        if (isInInitialState) {
            if (sender.currentTitle == "0") {
                // do nothing
                return
            } else {
                clearButton.setTitle("C", for: .normal)
                isInInitialState = false
                currentOperand = sender.currentTitle!
                resultDisplayField.text = currentOperand
            }
        } else {
            if (wasLastButtonClickedAnOperator) {
                currentOperand = sender.currentTitle!
            } else {
                currentOperand = (resultDisplayField.text?.appending(sender.currentTitle!))!
            }
            resultDisplayField.text = currentOperand
        }
        
        wasLastButtonClickedAnOperator = false
    }
    
    @IBAction func onDecimalPointClicked(_ sender: RoundButton) {
        
        if (wasLastButtonClickedAnOperator) {
            currentOperand = "0"
        }
        
        if (!currentOperand.contains(".")) {
            if (wasLastButtonClickedAnOperator) {
                currentOperand = "0."
            } else {
            currentOperand = (resultDisplayField.text?.appending(sender.currentTitle!))!
            }
            
            resultDisplayField.text = currentOperand
            isInInitialState = false
        }
        wasLastButtonClickedAnOperator = false
    }
    
    @IBAction func onOperatorClicked(_ sender: RoundButton) {
        operands.append(currentOperand)
        
        // Evaluate and display the result of the expression till now if the latest operator pressed is of lower precedence than the previous ones.
        if (operands.count > 1) {
            
            let isCurrentOperatorOfHigherPrecedence : Bool =
                (getOperatorPrecedence(argOperator: sender.currentTitle!) > getOperatorPrecedence(argOperator: operators.last!))
            
            
            if (!isCurrentOperatorOfHigherPrecedence) {
                let result : Float = evaluateResult(operators: operators, operands: operands)
                // If the float result has a value of 0 after decimal point, then show the result as an integer.
                if (floor(result) == result) {
                    resultDisplayField.text = String(Int(result))
                } else {
                    resultDisplayField.text = String(result)
                }
            }
        }
        
        operators.append(sender.currentTitle!)
        currentOperand = "0"
        wasLastButtonClickedAnOperator = true
    }
    
    @IBAction func onEqualsButtonClicked(_ sender: RoundButton) {
        operands.append(currentOperand)
        
        let result : Float = evaluateResult(operators: operators, operands: operands)
        // If the float result has a value of 0 after decimal point, then show the result as an integer.
        if (floor(result) == result) {
            resultDisplayField.text = String(Int(result))
        } else {
            resultDisplayField.text = String(result)
        }
        
        operands.removeAll()
        operands.append(String(result))
        if (operators.count > 1) {
            operators.removeSubrange(Range(0...(operators.count - 2)))
        }
        
        wasLastButtonClickedAnOperator = true
    }
    
    func evaluateResult(operators: [String], operands: [String]) -> Float {
        var result : Float
        var operatorPosition : Int = -1
        var operand1 : Float
        var operand2 : Float
        var mutableOperatorsArray = operators
        var mutableOperandsArray = operands
        
        if (mutableOperatorsArray.index(of: "/") != nil) {
            currentOperator = DIVISION_OPERATOR
            operatorPosition = mutableOperatorsArray.index(of: "/")!
        } else if (mutableOperatorsArray.index(of: "x") != nil) {
            currentOperator = MULTIPLICATION_OPERATOR
            operatorPosition = mutableOperatorsArray.index(of: "x")!
        } else if (mutableOperatorsArray.index(of: "+") != nil) {
            currentOperator = ADDITION_OPERATOR
            operatorPosition = mutableOperatorsArray.index(of: "+")!
        } else if (mutableOperatorsArray.index(of: "-") != nil) {
            currentOperator = SUBTRACTION_OPERATOR
            operatorPosition = mutableOperatorsArray.index(of: "-")!
        }

        operand1 = Float(mutableOperandsArray[operatorPosition])!
        operand2 = Float(mutableOperandsArray[operatorPosition + 1])!
        
        result = evalStatement(argOperator: currentOperator, operand1: operand1, operand2: operand2)
        
        if (mutableOperandsArray.count >= 2) {
            mutableOperatorsArray.remove(at: operatorPosition)
            // Replace the two operands with their result after evaluating
            mutableOperandsArray.replaceSubrange(Range(operatorPosition...operatorPosition.advanced(by: 1)), with: [String(result)])
        }
        
        if (mutableOperandsArray.count >= 2) {
            result = evaluateResult(operators: mutableOperatorsArray, operands: mutableOperandsArray)
        }
        
        return result
    }
    
    func evalStatement(argOperator: Int, operand1: Float, operand2: Float) -> Float {
        switch argOperator {
        case DIVISION_OPERATOR:
            return operand1 / operand2
        case MULTIPLICATION_OPERATOR:
            return operand1 * operand2
        case ADDITION_OPERATOR:
            return operand1 + operand2
        case SUBTRACTION_OPERATOR:
            return operand1 - operand2
        default:
            print("Received an unknown operator : " + String(argOperator))
            return 0
        }
    }
    
    func getOperatorPrecedence(argOperator: String) -> Int {
        switch argOperator {
        case "/":
            return DIVISION_OPERATOR
        case "x":
            return MULTIPLICATION_OPERATOR
        case "+":
            return ADDITION_OPERATOR
        case "-":
            return SUBTRACTION_OPERATOR
        default:
            print("Received an unknown operator : " + argOperator)
            return -1
        }
    }
    
    @IBAction func onResetButtonClicked(_ sender: RoundButton) {
        sender.setTitle("AC", for: .normal)
        resultDisplayField.text = "0"
        isInInitialState = true
        currentOperand = "0"
        operators.removeAll()
        operands.removeAll()
    }
    
}

