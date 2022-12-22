/**
 * @file register-command.js is to regularly update the discord slash command
 * @author Alfian Firmansyah <alfianvansykes@gmail.com>
 * @version 1.0
 */

import {
  REST,
  Routes
} from 'discord.js';
import cron from 'node-cron';

import dotenv from 'dotenv'
dotenv.config({
  path: `${process.env.NODE_ENV}.env`
});
import {
  readFileSync
} from 'fs';

export default async function registerCommand() {
  cron.schedule('* * * * *', async () => {

    // object payload top up
    let topupData = readFileSync('json_database/topup-item-payload.json');
    let tpList = JSON.parse(topupData);
    // clean json data, retain only name and value 
    tpList = tpList.map(({
      itemId,
      qty,
      bonus,
      ...rest
    }) => ({
      ...rest
    }))

    // object payload share event
    let rewardData = readFileSync('json_database/share-event.json');
    let rList = JSON.parse(rewardData);
    // clean json data, retain only name and value 
    tpList = tpList.map(({
      itemId,
      qty,
      bonus,
      ...rest
    }) => ({
      ...rest
    }))

    // object payload share event
    let dcRewardData = readFileSync('json_database/discord-reward.json');
    let dcList = JSON.parse(dcRewardData);
    // clean json data, retain only name and value 
    dcList = dcList.map(({
      itemId,
      qty,
      bonus,
      ...rest
    }) => ({
      ...rest
    }))

    // genearate payload multiplication
    var numberOfMultiplication = []
    for (let i = 0; i < 20; i++) {
      numberOfMultiplication.push({
        name: `${i+1}`,
        value: i + 1
      })
    }

    const commands = [{
        name: 'ping',
        description: 'Replies with gnome server status!',
      },
      {
        name: 'help',
        description: 'What can I do for you?'
      },
      {
        name: 'tplist',
        description: 'Gnome top up list'
      },
      {
        name: 'tpsend',
        description: 'Send top up gnome',
        options: [{
            name: 'uid',
            description: 'player user id',
            type: 4,
            required: true
          },
          {
            name: 'top-up-number',
            description: 'Pick one of the top up item',
            type: 3,
            required: true,
            choices: tpList
          },
          {
            name: 'multiplication',
            description: 'pick multiplication 1 - 20',
            type: 4,
            required: true,
            choices: numberOfMultiplication
          },
          {
            name: 'confirm',
            description: 'Are you sure want to send this now?',
            type: 4,
            required: true,
            choices: [{
              name: 'Yes',
              value: 1
            }, {
              name: 'No',
              value: 0
            }]
          },
          {
            name: 'is-first-bonus',
            description: 'You can fill this with `1` If this is the first order, or just ignore the bonus if none.',
            type: 4,
            choices: [{
              name: 'Yes',
              value: 1
            }, {
              name: 'No',
              value: 0
            }]
          }
        ]
      },
      {
        name: 'rsend',
        description: 'Send rewards gnome',
        options: [{
            name: 'uid',
            description: 'player user id',
            type: 4,
            required: true
          },
          {
            name: 'top-up-number',
            description: 'Pick one of the top up item',
            type: 3,
            required: true,
            choices: rList
          },
          {
            name: 'multiplication',
            description: 'pick multiplication 1 - 20',
            type: 4,
            required: true,
            choices: [{
              name: '1',
              value: 1
            }]
          },
          {
            name: 'confirm',
            description: 'Are you sure want to send this now?',
            type: 4,
            required: true,
            choices: [{
              name: 'Yes',
              value: 1
            }, {
              name: 'No',
              value: 0
            }]
          }
        ]
      },
      {
        name: 'dcsend',
        description: 'Send discord badge rewards gnome',
        options: [{
            name: 'uid',
            description: 'player user id',
            type: 4,
            required: true
          },
          {
            name: 'top-up-number',
            description: 'Pick one of the top up item',
            type: 3,
            required: true,
            choices: dcList
          },
          {
            name: 'multiplication',
            description: 'pick multiplication 1 - 20',
            type: 4,
            required: true,
            choices: [{
              name: '1',
              value: 1
            }]
          },
          {
            name: 'confirm',
            description: 'Are you sure want to send this now?',
            type: 4,
            required: true,
            choices: [{
              name: 'Yes',
              value: 1
            }, {
              name: 'No',
              value: 0
            }]
          }
        ]
      }
    ];

    const rest = new REST({
      version: '10'
    }).setToken(process.env.TOKEN);

    (async () => {
      try {
        console.log('Started refreshing application (/) commands.');

        await rest.put(Routes.applicationCommands(process.env.CLIENT_ID), {
          body: commands
        });

        console.log('Successfully reloaded application (/) commands.');
      } catch (error) {
        console.error(error);
      }
    })();
  });
}