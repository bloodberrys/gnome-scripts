import dotenv from 'dotenv'
dotenv.config({
    path: `${process.env.NODE_ENV}.env`
});

import {
    Configuration,
    OpenAIApi
} from 'openai';

import {
    readFileSync,
    createReadStream
} from 'fs';

async function imageChatGPT(prompt = 'porn') {

    const configuration = new Configuration({
        apiKey: process.env.OPENAI_API_KEY,
    });
    const openai = new OpenAIApi(configuration);

    try {
        const image = await openai.createImage({
            prompt: String(prompt),
            n: 1,
            size: "1024x1024"
        });
        console.log(image.data.data[0].url)
        return image.data.data[0].url;
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
async function imageEditChatGPT(prompt = 'A person with christmas hat', raw_image = '/Users/alfian.firmansyah/Downloads/GnomeArt/CrusaderDragon3.png', mask = '/Users/alfian.firmansyah/Downloads/Santa-Claus-Hat-PNG-Images.png') {

    const configuration = new Configuration({
        apiKey: process.env.OPENAI_API_KEY,
    });
    const openai = new OpenAIApi(configuration);

    console.log(createReadStream(mask))
    console.log(raw_image)

    try {
        const image = await openai.createImageEdit({
            image: createReadStream(raw_image),
            mask: createReadStream(mask),
            prompt: String(prompt),
            n: 1,
            size: "1024x1024"
        });
        console.log(image.data.data[0].url)
        return image.data.data[0].url;
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

imageEditChatGPT()