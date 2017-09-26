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
    
    // Operators with precedence orders (Higher value corresponds to Higher precedence level).
    let DIVISION_OPERATOR = 4
    let MULTIPLICATION_OPERATOR = 3
    let ADDITION_OPERATOR = 2
    let SUBTRACTION_OPERATOR = 1
    
    // Flags
    // isInInitialState flag is true only when the app has just been launched or the last button clicked was the Reset button.
    var isInInitialState = true
    var wasLastButtonClickedAnOperator = false
    
    var currentOperator : Int!
    // currentOperand will always hold the last operand entered by user.
    var currentOperand : String = "0"
    
    // Arrays to hold operands and operators in the order user inputs them.
    var operands = [String]()
    var operators = [String]()
    
    
    // OUTLETS +++++++++++++++++++++++++++
    
    @IBOutlet weak var resultDisplayField: RoundLabel!
    @IBOutlet weak var clearButton: RoundButton!
    
    
    // ACTIONS METHODS ++++++++++++++++++++++++++++
    
    @IBAction func onNumberClicked(_ sender: RoundButton) {
        
        if (isInInitialState) {
            if (sender.currentTitle == "0") {
                // do nothing
                return
            } else {
                isInInitialState = false
                currentOperand = sender.currentTitle!
                resultDisplayField.text = currentOperand
            }
        } else {
            /* If the last button clicked was an operator, that means user has just started to enter a new operand.
             * If the last button clicked was NOT an operator, that means user is in the middle of entering an operand
             , hence continue appending the digits.
             */
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
        // If the decimal point was clicked just after an operator button, reset the currentOperand to 0.
        if (wasLastButtonClickedAnOperator) {
            resetCurrentOperandToZero()
        }
        
        // Do NOT add another decimal point if the partial currentOperand already has one decimal point.
        if (!currentOperand.contains(".")) {
            if (wasLastButtonClickedAnOperator) {
                currentOperand = currentOperand.appending(".")
            } else {
                currentOperand = (resultDisplayField.text?.appending(sender.currentTitle!))!
            }
            
            resultDisplayField.text = currentOperand
            isInInitialState = false
        }
        wasLastButtonClickedAnOperator = false
    }
    
    @IBAction func onOperatorClicked(_ sender: RoundButton) {
        // If the previous button clicked was also an operator, simply replace the last operator with the current one.
        if (wasLastButtonClickedAnOperator) {
            operators[operators.count - 1] = sender.currentTitle!
        } else {
            
            // As soon as an operator is clicked, Add the lastest operand entered by user into the array of operands.
            operands.append(currentOperand)
            
            /* If the number of operands in the array is 2 or more, that means there is already an expression that could possibly be evaluated and displayed
             * to the user if the operator precedence conditions are met.
             */
            if (operands.count > 1) {
                
                // Find whether the currently clicked operator has a higher precedence order than the last operator in the list of operators.
                let isCurrentOperatorOfHigherPrecedence : Bool =
                    (getOperatorPrecedence(paramOperator: sender.currentTitle!) > getOperatorPrecedence(paramOperator: operators.last!))
                
                // If the current operator clicked is of a lower precedence than the previous ones, then the expression until now (excluding the current operator) can safely be evaluated and displayed to the user.
                if (!isCurrentOperatorOfHigherPrecedence) {
                    let result : Float = evaluateExpression(operators: operators, operands: operands)
                    
                    if (result.isInfinite || result.isNaN) {
                        handleError(result: result)
                    } else {
                        // If the float result has a value of 0 after decimal point, then show the result as an integer.
                        if (floor(result) == result) {
                            resultDisplayField.text = String(Int(result))
                        } else {
                            resultDisplayField.text = String(result)
                        }
                    }
                }
            }
            
            operators.append(sender.currentTitle!)
            resetCurrentOperandToZero()
            wasLastButtonClickedAnOperator = true
        }
    }
    
    @IBAction func onEqualsButtonClicked(_ sender: RoundButton) {
        if (operators.isEmpty) {
            return
        }
        
        operands.append(currentOperand)
        
        let result : Float = evaluateExpression(operators: operators, operands: operands)
        
        if (result.isInfinite || result.isNaN) {
            handleError(result: result)
        } else {
            // If the fractional part of the float result has a value of 0, then display the result as an integer only.
            if (floor(result) == result) {
                resultDisplayField.text = String(Int(result))
            } else {
                resultDisplayField.text = String(result)
            }
            
            // Once the result has been calculated and displayed, clear all operands from the array and replace them just by the final result value we got (for our future use).
            operands.removeAll()
            operands.append(String(result))
            
            // If there are more than one operators in the list, clear them all except just the last one (again for our use in case user presses Equals button again).
            if (operators.count > 1) {
                operators.removeSubrange(Range(0...(operators.count - 2)))
            }
        }
        
        wasLastButtonClickedAnOperator = true
    }
    
    @IBAction func onResetButtonClicked(_ sender: RoundButton) {
        resultDisplayField.text = "0"
        resetData()
    }
    
    // CUSTOM METHODS +++++++++++++++++++++++++++++++
    
    
    /// This methods evaluates the complete expression which may have contain multiple operators and operands while keeping in mind the operator precedence order.
    ///
    /// - Parameters:
    ///   - operators: The array of operators in the order user clicked them.
    ///   - operands: The array of operands in the order user entered them.
    /// - Returns: Returns the fully evaluated result of expression.
    func evaluateExpression(operators: [String], operands: [String]) -> Float {
        var firstOperand : Float
        var secondOperand : Float
        var result : Float
        var operatorIndexInArray : Int!
        var tempOperatorsArray = operators
        var tempOperandsArray = operands
        
        // Find the operator positions and evaluate their respective associated statements one by one starting with the operators of highest precedence.
        if (tempOperatorsArray.index(of: "/") != nil) {
            currentOperator = DIVISION_OPERATOR
            operatorIndexInArray = tempOperatorsArray.index(of: "/")!
        } else if (tempOperatorsArray.index(of: "x") != nil) {
            currentOperator = MULTIPLICATION_OPERATOR
            operatorIndexInArray = tempOperatorsArray.index(of: "x")!
        } else if (tempOperatorsArray.index(of: "+") != nil) {
            currentOperator = ADDITION_OPERATOR
            operatorIndexInArray = tempOperatorsArray.index(of: "+")!
        } else if (tempOperatorsArray.index(of: "-") != nil) {
            currentOperator = SUBTRACTION_OPERATOR
            operatorIndexInArray = tempOperatorsArray.index(of: "-")!
        }
        
        // Find the associated first and second operands of the currentOperator.
        firstOperand = Float(tempOperandsArray[operatorIndexInArray])!
        secondOperand = Float(tempOperandsArray[operatorIndexInArray + 1])!
        
        result = evaluateStatement(selectedOperator: currentOperator, firstOperand: firstOperand, secondOperand: secondOperand)
        
        // If the result is invalid, don't proceed with any further evaluation and return the result immediately.
        if (result.isInfinite || result.isNaN) {
            return result
        }
        
        // Remove the operator whose statement was just evaluated, from the operators array and replace the two entries of its associated operands with a single entry of the result of the statement.
        if (tempOperandsArray.count >= 2) {
            tempOperatorsArray.remove(at: operatorIndexInArray)
            // Replace the two operands with their result after evaluating
            tempOperandsArray.replaceSubrange(Range(operatorIndexInArray...operatorIndexInArray.advanced(by: 1)), with: [String(result)])
        }
        
        // If there are still 2 or more operands left in the array, that means the evaluation of expression has not yet completed, hence, call the same method in recursion but with the updated tempOperatorsArray and tempOperandsArray.
        if (tempOperandsArray.count >= 2) {
            result = evaluateExpression(operators: tempOperatorsArray, operands: tempOperandsArray)
        }
        
        return result
    }
    
    
    /// Evaluate the individual statement of an operator with two operands.
    ///
    /// - Parameters:
    ///   - selectedOperator: The operator between the two operands.
    /// - Returns: The result of the statement evaluated.
    func evaluateStatement(selectedOperator: Int, firstOperand: Float, secondOperand: Float) -> Float {
        switch selectedOperator {
        case DIVISION_OPERATOR:
            return firstOperand / secondOperand
        case MULTIPLICATION_OPERATOR:
            return firstOperand * secondOperand
        case ADDITION_OPERATOR:
            return firstOperand + secondOperand
        case SUBTRACTION_OPERATOR:
            return firstOperand - secondOperand
        default:
            // We're not supposed to reach here. Print the unknown operator for debugging and send the result as NaN.
            print("Received an unknown operator : " + String(selectedOperator))
            return .nan
        }
    }
    
    
    /// Get the precedence order of an operator.
    ///
    /// - Parameter paramOperator: The operator whose precedence is to be known.
    /// - Returns: Returns the precedence of the operator as an integer.
    func getOperatorPrecedence(paramOperator: String) -> Int {
        switch paramOperator {
        case "/":
            return DIVISION_OPERATOR
        case "x":
            return MULTIPLICATION_OPERATOR
        case "+":
            return ADDITION_OPERATOR
        case "-":
            return SUBTRACTION_OPERATOR
        default:
            // We're not supposed to reach here. Print the unknown operator for debugging.
            print("Received an unknown operator : " + paramOperator)
            return -1
        }
    }
    
    
    /// This method handles in case an error occurs while evaluation of expression by displaying an appropriate error message to the user and resetting the flags and user entered data.
    ///
    /// - Parameter result: The result received after evaluation of expression.
    func handleError(result: Float) {
        if (result.isInfinite) {
            resultDisplayField.text = "Infinity !!!"
        } else if (result.isNaN) {
            resultDisplayField.text = "Bad Expression !!!"
        }
        resetData()
    }
    
    
    /// Reset the flags and user entered data.
    func resetData () {
        isInInitialState = true
        resetCurrentOperandToZero()
        operators.removeAll()
        operands.removeAll()
    }
    
    
    /// Resets the "currentOperand" field back to 0.
    func resetCurrentOperandToZero() {
        currentOperand = "0"
    }
    
}

