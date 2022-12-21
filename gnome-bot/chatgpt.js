import dotenv from 'dotenv'
dotenv.config()

import {
    Configuration,
    OpenAIApi
} from 'openai';

export default async function chatGPT(prompt) {

    const configuration = new Configuration({
        apiKey: process.env.OPENAI_API_KEY,
    });
    const openai = new OpenAIApi(configuration);

    try {
        const completion = await openai.createCompletion({
            model: "text-davinci-003",
            prompt: String(prompt),
            max_tokens: 1000,
            temperature: 0
        });
        console.log(completion.data)
        return completion.data.choices[0].text;
    } catch (error) {
        if (error.response) {
            console.log(error.response.status);
            console.log(error.response.data);
            return error.response.status + ', ' + error.response.data;
        } else {
            console.log(error.message);
            return error.message
        }
    }
}