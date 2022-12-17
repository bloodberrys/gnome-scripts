import {
  REST,
  Routes
} from 'discord.js';
import dotenv from 'dotenv'
import cron from 'node-cron';
dotenv.config()

export default async function registerCommand() {
  cron.schedule('* * * * *', async () => {
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
          }, {
            name: 'top-up-number',
            description: 'top up donation list number (1 - 12), please check with `/tplist` command',
            type: 3,
            required: true
          }, {
            name: 'multiplication',
            description: 'pick multiplication 1 - 20',
            type: 4,
            required: true
          },
          {
            name: 'is-first-bonus',
            description: 'You can fill this with `1` If this is the first order, or just ignore the bonus if none.',
            type: 4
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