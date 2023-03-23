import dotenv from 'dotenv'
dotenv.config({
    path: `${process.env.NODE_ENV}.env`
});

import {
    Configuration,
    OpenAIApi
} from 'openai';

export default async function moderationChatGPT(input) {

    const configuration = new Configuration({
        apiKey: process.env.OPENAI_API_KEY,
    });
    const openai = new OpenAIApi(configuration);

    try {
        const moderation = await openai.createModeration({
            input: String(input)
        });
        console.log(moderation.data.results[0])
        return moderation.data.results[0];
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