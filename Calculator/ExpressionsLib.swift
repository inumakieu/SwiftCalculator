import Foundation

extension Double {
    @inlinable
    func signum( ) -> Self {
        if self < 0 { return -1 }
        if self > 0 { return 1 }
        return 0
    }
}

func forTrailingZero(temp: Double) -> String {
    var tempVar = String(format: "%g", temp)
    return tempVar
}

func factorial(number : Double) -> Double {
    var result = 1.0;
    
    for i in 2...Int(number) {
        result = result * Double(i);
    }
    
    return Double(result)
}

extension String: Error {}

class ExpressionsLib {
    struct isValidOutput{
        var passes : Bool
        var message : String
    }
    
    struct Operator{
        var id : Int
        func evaluate() {}
        func isValidInput() {}
    }
    
    struct UnaryOperator {
        var id : Int
        func evaluate (num: Double) -> Double {
            switch id {
            case 5:
                return log(num)
            case 6:
                return sqrt(num)
            case 7:
                return (num * -1)
            case 8:
                return (num * +1)
            case 9:
                return factorial(number: num)
            default:
                return 0.0
            }
        }
        func isValidInput (num: Double) -> isValidOutput {
            switch id {
            case 5:
                if(num <= 0) {
                    return isValidOutput(passes: false, message: "Domain error")
                }
                return isValidOutput(passes: true, message: "")
            case 6:
                if(num <= 0) {
                    return isValidOutput(passes: false, message: "Keep it real")
                }
                return isValidOutput(passes: true, message: "")
            case 7:
                return isValidOutput(passes: true, message: "")
            case 8:
                return isValidOutput(passes: true, message: "")
            case 9:
                if(fmod(num, 1) != 0 || num < 0){
                    return isValidOutput(passes: true, message: "You can't take a factorial of a " + (fmod(num, 1) != 0 ? "non-integer" : "negative number"))
                }
                return isValidOutput(passes: true, message: "")
            default:
                return isValidOutput(passes: false, message: "IDK")
            }
        }
    }
    
    struct pendingUnaryObject{
        var _operator : String
        var bracesNum : Int
    }
    struct BinaryOperator {
        var id : Int
        func evaluate (num1 : Double, num2 : Double) -> Double {
            switch id {
            case 0:
                return pow(num1, num2)
            case 1:
                return num1 / num2
            case 2:
                return num1 * num2
            case 3:
                return num1 + num2
            case 4:
                return num1 - num2
            default:
                return 0.0
            }
        }
        func isValidInput (num1 : Double, num2 : Double) -> isValidOutput {
            switch id {
            case 0:
                return isValidOutput(passes: true, message: "")
            case 1:
                if(num2 == 0){
                    return isValidOutput(passes: false, message: "You can't divide by 0")
                }
                return  isValidOutput(passes: true, message: "")
            case 2:
                return isValidOutput(passes: true, message: "")
            case 3:
                return isValidOutput(passes: true, message: "")
            case 4:
                return isValidOutput(passes: true, message: "")
            default:
                return isValidOutput(passes: false, message: "IDK")
            }
        }
    }
    var OperatorsObject = [String : Operator]()
    var UnaryOperatorsObject = [String : UnaryOperator]()
    var BinaryOperatorsObject = [String : BinaryOperator]()
    
    struct StackElement{
        var isOperator : Bool
        var isBracket : Bool
        var value : Double
    }
    
    
    
    
    let BEDMAS = ["^", "/", "*", "+", "-"];
    
    let binaryOperations : [String : BinaryOperator] =
    [
        "^": BinaryOperator(
            id: 0
        ),
        "/": BinaryOperator(
            id: 1
        ),
        "*": BinaryOperator(
            id: 2
        ),
        "+": BinaryOperator(
            id: 3
        ),
        "-": BinaryOperator(
            id: 4
        )
    ]
    
    
    let unaryOperators : [String : UnaryOperator] =
    [
        "ln": UnaryOperator(
            id: 5
        ),
        "sqrt": UnaryOperator(
            id: 6
        ),
        "-": UnaryOperator(
            id: 7
        ),
        "+": UnaryOperator(
            id: 8
        ),
    ]
    let postUnaryOperators : [String : UnaryOperator] = [
        "!" : UnaryOperator(id: 9)
    ]
    
    var mapOperatorToId : [String : Int] = [:]
    var allOperators : [[String : Any]]
    var operatorIDs: [Int] = []
    
    
    init() {

        allOperators = [unaryOperators, postUnaryOperators, binaryOperations]
        mapOperatorToId = [
            "^": 0,
            "/": 1,
            "*": 2,
            "+": 3,
            "-": 4,
            "ln": 5,
            "sqrt": 6,
            "!": 9,
        ]
        
    }
    
    func evaluateBinaryExpression(num1 : Double, num2 : Double, operation : String) throws -> Double {
        
        let canEvaluate = binaryOperations[operation]?.isValidInput(num1: num1, num2: num2);
        
        if(canEvaluate != nil && canEvaluate!.passes){
            return (binaryOperations[operation]?.evaluate(num1: num1, num2: num2))!;
        }else{
            // TODO: add error handling here
            throw canEvaluate!.message
        }
    }
    
    func evaluateUnaryExpression(num : Double, operation : String) throws -> Double {
        let canEvaluate = unaryOperators[operation]?.isValidInput(num: num);
        
        if(canEvaluate != nil && canEvaluate!.passes){
            return unaryOperators[operation]!.evaluate(num: num);
        }else{
            // TODO: add error handling here
            throw canEvaluate!.message
        }
    }
    
    func evaluatePostUnaryExpression(num : Double, operation : String) throws -> Double {
        let canEvaluate = postUnaryOperators[operation]?.isValidInput(num: num);
        
        if(canEvaluate != nil && canEvaluate!.passes){
            return postUnaryOperators[operation]!.evaluate(num: num);
        }else{
            // TODO: add error handling here
            throw canEvaluate!.message
        }
    }
    
    /**
     * Checks if a stack element is represents a number
     * @param elem the element that needs to be checked
     * @returns true if does represent a number; false otherwise.
     */
    func isNum(elem : StackElement) -> Bool {
        if(elem == nil) {
            return false
        }
        return elem.isBracket == false && elem.isOperator == false;
    }
    
    /**
     * Evaluates a subexpression.
     * Subexpression in this context means an expression that does not
     * have any braces and consists only of binary operations.
     * For example:
     * 5 + 4 * 30 / 4 -- is a sub expression
     * However, 5 + 4 * (30 / 4) and 5! + 4 * 30 / 4 are not
     * sub expressions
     * @param exp the expression that needs to be evaluated
     * @returns a single numerical stack element
     */
    func evaluateSubExpression(expo: [StackElement]) throws -> StackElement {

        var exp = expo
        for j in 0...BEDMAS.count-1 {
            let op = BEDMAS[j];
            let operationID =  Int(mapOperatorToId[mapOperatorToId.index(forKey: op)!].value);

            var i = 0;
            while(i < exp.count){
                if(exp[i].isOperator && (Int(exp[i].value) == operationID)) {


                    if(exp[i + 1].value == -1 && exp[i + 1].isOperator){

                        if(!isNum(elem: exp[i + 2]))
                        {
                            // TODO: add error handling here
                            throw "Syntax Error"
                        }

                        exp[i + 2].value *= -1;
                        exp[i + 1] =  exp[i + 2];
                        exp.removeSubrange(i+2...i+2);
                    }

                    // If the elements surrounding the operator are not
                    // numbers, then it means that there is
                    // a syntax error somewhere

                    if(!isNum(elem: exp[i - 1]) || !isNum(elem: exp[i + 1]))
                    {
                        // TODO: add error handling here
                        throw "Syntax Error"
                    }
                    let num1 = exp[i - 1].value;
                    let num2 = exp[i + 1].value;
                    do {
                        exp[i - 1].value = try evaluateBinaryExpression(num1: num1, num2: num2, operation: op);
                    } catch {
                        throw error
                    }
                    exp.removeSubrange(i...i+1)
                    i-=1;
                }

                i+=1;
            }

        }
        

        var i = 0;
        while(i < exp.count){
            if (exp[i].value == -1 && exp[i].isOperator) {
                if (!isNum(elem: exp[i + 1])) {
                    print("oops")
                    // TODO: add error handling here
                    throw "Syntax Error"
                }
                exp[i + 1].value *= -1;
                exp[i] = exp[i + 1];
                exp.removeSubrange(i+1...i+1);
            }

            i+=1;
        }


        return StackElement(isOperator: false, isBracket: false, value: exp[0].value)
    }
    
    func evaluateExpression(expo: String) throws -> Double {
        var exp = expo
        var stack : [StackElement] = [];
        
        var numberOfUnclosedBrackets = 0;
        exp = exp.replacingOccurrences(of: " ", with: "")
        exp = "(" + exp + ")";
        
        var number = 0.0;
        var decimalNumber = "";
        var firstNumber = true;
        var decimalFirst = true;
        var decimalStart = false;
        var pendingUnary : Array<pendingUnaryObject> = [];
        
        var isMinusUnary = false;
        var isMinusForNumber = true;
        var minusCoef = -1;
        var haveToUseCoef = false;
        var isPlusUnary = false;
        
        var isMinusPlusChain = false;
        
        var i = -1;

        while(true) {

            i+=1
            if(i >= exp.count){
                break;
            }
            
            var current = exp[exp.index(exp.startIndex, offsetBy: i)]

            var isNumber = Double(String(current)) != nil ? !Double(String(current))!.isNaN : false
            
            var didAdd = false;


            // Checking if the character is a number
            if(isNumber || current == "."){
                didAdd = true;
                
                if (isMinusForNumber) {
                    haveToUseCoef = true;
                }
                
                
                // Assigning the digit if it is the
                // the first digit of the number
                if(firstNumber){
                    var currentNumber = Int(String(current))!
                    number = Double(currentNumber);
                    firstNumber = false;
                }else{
                    
                    // Checking if it has decimal places
                    if(current == "."){
                        decimalStart = true;
                    }else if(decimalStart){
                        var currentNumber = Int(String(current))!
                        
                        // Calculating the decimal part of the
                        // number as an integer
                        if(decimalFirst){
                            decimalNumber = String(currentNumber)
                            decimalFirst = false;
                        }else{
                            decimalNumber = decimalNumber + String(currentNumber)
                        }
                    }else{
                        var currentNumber = Int(String(current))!
                        // Parsing the string as an Integer
                        number = number*10 + Double(currentNumber);
                    }
                }
                
                continue
                
            }else if(firstNumber == false){
                
                if (haveToUseCoef) {
                    number = number * Double(minusCoef);
                }
                
                
                // If the last item added to the stack was
                // a bracket, then we can assume that this number has
                // to be multiplied by the expression that
                // is preceded by this bracket
                if(stack.count > 0 && isNum(elem: stack[stack.count - 1])){
                    stack.append(StackElement(isOperator: true, isBracket: false, value: Double(mapOperatorToId[mapOperatorToId.index(forKey: "*")!].value)))
                }
                
                // Adding decimal places if needed
                if(decimalStart){
                    number = number + (number.signum() == 0 ? 1 : number.signum()) * Double("0." + decimalNumber)!;
                }
                
                // Adding the number to the stack
                stack.append(StackElement(isOperator: false, isBracket: false, value: number))
                
                
                // Resetting values
                minusCoef = -1;
                decimalNumber = "";
                firstNumber = true;
                decimalStart = false;
                decimalFirst = false;
                haveToUseCoef = false;
                
            }


            if(stack.count > 0 && isNum(elem: stack[stack.count - 1])){
                
                var shouldContinue = false;
                // Applying unary operators that are there
                // after the number
                for op in postUnaryOperators {
                    
                    if(i + op.key.count >= exp.count){
                        continue;
                    }
                    let start = exp.index(exp.startIndex, offsetBy: i)
                    let end = exp.index(exp.startIndex, offsetBy: i + op.key.count - 1)

                    if(String(exp[start...end]) == op.key) {
                        
                        didAdd = true;
                        
                        let value = stack[stack.count - 1].value;
                        do {
                            stack[stack.count - 1].value = try evaluatePostUnaryExpression(num: value, operation: op.key);
                        } catch {
                            throw error
                        }
                        
                        i = i + op.key.count - 1;
                        shouldContinue = true;
                        
                        break;
                    }
                }
                if(shouldContinue) {continue}
            }



            if(stack.count > 0 &&
               (stack[stack.count - 1].isBracket || stack[stack.count - 1].isOperator) &&
               (current == "-" || current == "+")){
                
                didAdd = true;
                var nextElem = exp[exp.index(exp.startIndex, offsetBy: i + 1)];
                if (nextElem == "-" || nextElem == "+") {

                    if(isMinusPlusChain){
                        minusCoef *= (current == "-") ? -1 : 1;
                    }else{
                        minusCoef = (current == "-") ? -1 : 1;
                    }
                    
                    isMinusPlusChain = true;
                    isMinusUnary = false;
                    isMinusForNumber = false;
                    continue;
                }
                else if(nextElem == "("){
                    // If the next characted is a bracket
                    // we can assume that the unary operator
                    // is being performed on an expression
                    if(isMinusPlusChain){
                        minusCoef *= (current == "-") ? -1 : 1;
                    }else{
                        minusCoef = (current == "-") ? -1 : 1;
                    }

                    isMinusUnary = true;
                    isMinusForNumber = false;
                    isMinusPlusChain = false;
                    // continue;
                }
                else{
                    // If the next characted is a bracket
                    // we can assume that the unary operator
                    // is being performed on an expression

                    if(isMinusPlusChain){
                        minusCoef *= (current == "-") ? -1 : 1;
                    }else{
                        minusCoef = (current == "-") ? -1 : 1;
                    }

                    isMinusUnary = false;
                    isMinusForNumber = true;
                    isMinusPlusChain = false;

                    continue;
                }
            }else{
                isMinusPlusChain = false;
                isMinusUnary = false;
                isMinusForNumber = false;
            }


            if(current == "("){
                
                // Incrementing the number of unclosed brackets
                numberOfUnclosedBrackets += 1
                
                // If the last item added to the stack was
                // a number, then we can assume that it has
                // to be multiplied by the expression that
                // is followed by this bracked
                if(stack.count > 0 && isNum(elem: stack[stack.count - 1])){
                    stack.append(StackElement(isOperator: true, isBracket: false, value: Double(mapOperatorToId[mapOperatorToId.index(forKey: "*")!].value)))
                }
                
                stack.append(StackElement(isOperator: false, isBracket: true, value: 0.0))
                
            }else if(current == ")" || i == (exp.count - 1)){
                
                // Decrementing the number of unclosed brackets
                numberOfUnclosedBrackets -= 1;
                
                stack.append(StackElement(isOperator: false, isBracket: true, value: 1.0));
                
                // Now we can evaluate the expression that is enclosed
                // by the brackets
                var subExpression : [StackElement] = [];
                var lastChar : StackElement;
                // Adding the items that need to be evaluated
                repeat {
                    lastChar = stack.popLast()!;
                    if(!lastChar.isBracket){

                        subExpression.insert(lastChar, at: 0)
                    }
                    
                    // Breaking the look if we encounter an
                    // opening bracket
                    if(lastChar.isBracket && lastChar.value == 0){
                        break;
                    }
                    
                } while(stack.count > 0);
                
                
                if(subExpression.count == 0){
                    // TODO: add error handling here
                    throw "Syntax Error"
                }
                

                // Evaluating all the binary operations
                do {
                    stack.append(try evaluateSubExpression(expo: subExpression))
                } catch {
                    throw error
                }
                
                // Evaluating all the non-post unary operations (like sqrt)
                if(pendingUnary.count != 0 && pendingUnary[pendingUnary.count - 1].bracesNum == numberOfUnclosedBrackets){
                    
                    if(!isNum(elem: stack[stack.count - 1])){
                        // TODO: add error handling here
                        throw "Syntax Error"
                    }
                    do {
                        stack[stack.count - 1] = StackElement(isOperator: false, isBracket: false, value: try evaluateUnaryExpression(num: stack[stack.count - 1].value, operation: pendingUnary[pendingUnary.count - 1]._operator))
                        pendingUnary.popLast()
                    } catch {
                        throw error
                    }
                }
                
            }else {
                
                if(!isMinusUnary && !isPlusUnary){
                    // Adding the binary operators to an array
                    for op in binaryOperations {
                        
                        // Checking if the operator has been found in the string
                        let start = exp.index(exp.startIndex, offsetBy: i)
                        let end = exp.index(exp.startIndex, offsetBy: i + op.key.count - 1)

                        if(String(exp[start...end]) == op.key) {
                            didAdd = true;
                            i = i + op.key.count - 1;
                            
                            if(op.key == "-"){
                                stack.append(StackElement(isOperator: true, isBracket: false, value: Double(mapOperatorToId[mapOperatorToId.index(forKey: "+")!].value)))
                                
                                stack.append(StackElement(isOperator: false, isBracket: false, value: -1))
                                
                                stack.append(StackElement(isOperator: true, isBracket: false, value: Double(mapOperatorToId[mapOperatorToId.index(forKey: "*")!].value)))
                                
                            }else{
                                stack.append(StackElement(isOperator: true, isBracket: false, value: Double(mapOperatorToId[mapOperatorToId.index(forKey: op.key)!].value)))
                            }
                            break;
                        }
                    }
                }
                
                // Adding the unary operators to an array
                for op in unaryOperators{
                    
                    if(i + op.key.count >= exp.count){
                        continue;
                    }
                    // If the minus is binary, we don't want
                    // to add it to the list
                    if(op.key == "-" && !isMinusUnary){
                        continue;
                    } else if(op.key == "-"){
                        if(minusCoef == 1){
                            break;
                        }
                    }
                    
                    // Plus does't have any effect on
                    // a number as a unary operator
                    // so we can ignore it
                    if(op.key == "+"){
                        continue;
                    }
                    
                    
                  
                    let start = exp.index(exp.startIndex, offsetBy: i)
                    let end = i + op.key.count < exp.count ? exp.index(exp.startIndex, offsetBy: i + op.key.count - 1) : exp.endIndex
                    if(String(exp[start...end]) == op.key) {
                        didAdd = true;


                        i = i + op.key.count - 1;
                        


                        if(op.key == "-"){
                            // Special operator reserved for internal
                            // use only. It signifies that the value has
                            // to be negated

                            stack.append(StackElement(isOperator: true, isBracket: false, value: -1))
                        }else{
                            pendingUnary.append(pendingUnaryObject(_operator: op.key, bracesNum: numberOfUnclosedBrackets))
                        }
                        break;
                    }
                }
                
                if(!didAdd){
                    // TODO: add error handling here
                    throw "Illegal characters or syntax error"
                }
            }

        }


         if(numberOfUnclosedBrackets != 0){
            // TODO: add error handling here
             throw "Unbalanced brackets"
        }
        do {
            let value = try evaluateSubExpression(expo: stack).value;
            return value;
        } catch {
            throw error
        }
    }
}
