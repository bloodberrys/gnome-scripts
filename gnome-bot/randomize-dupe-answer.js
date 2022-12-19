/**
 * @file randomize-dupe-answer.js For example the bot find the word match, but it has many answer, we can do randomize the answer. 
 * @author Alfian Firmansyah <alfianvansykes@gmail.com>
 * @version 1.0
 */

export default function randomizeAnswer(jsonConversation, evaluatedWord) {
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