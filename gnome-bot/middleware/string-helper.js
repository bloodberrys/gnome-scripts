/**
 * @file string-helper.js 
 * Many tools here
 * For example the bot find the word match, but it has many answer, we can do randomize the answer.
 * or split 2000 discord limit string 
 * @author Alfian Firmansyah <alfianvansykes@gmail.com>
 * @version 1.0
 */

function splitString(n, str) {
    let arr;
    if (str) {
        arr = str.split(' ');
    }
    let result = []
    let subStr = arr[0]
    for (let i = 1; i < arr.length; i++) {
        let word = arr[i]
        if (subStr.length + word.length + 1 <= n) {
            subStr = subStr + ' ' + word
        } else {
            result.push(subStr);
            subStr = word
        }
    }
    if (subStr.length) {
        result.push(subStr)
    }
    return result
}

function randomizeAnswer(jsonConversation, evaluatedWord) {
    var allAnswers = []
    // Find the answer and push to array
    for (var i = 0; i < jsonConversation.length; i++) {
        // look for the entry with a matching `code` value
        if (jsonConversation[i].question === evaluatedWord) {
            // we found it
            // jsonConversation[i].name is the matched result
            console.log(jsonConversation[i])
            allAnswers.push(jsonConversation[i])
        }
    }

    // console.log(allAnswers)
    // console.log(allAnswers.length)

    function randomIntFromInterval(min, max) { // min and max included 
        return Math.floor(Math.random() * (max - min + 1) + min)
    }

    const rndInt = randomIntFromInterval(0, allAnswers.length - 1)
    // console.log(rndInt)

    var newRandomAnswer = [allAnswers[rndInt]]
    // console.log(newRandomAnswer)

    let answer = newRandomAnswer.find(x => x.question === String(evaluatedWord)).answer;

    return answer;
}


export {
    randomizeAnswer,
    splitString
};