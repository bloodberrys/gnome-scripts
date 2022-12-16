const {
  REST,
  Routes
} = require('discord.js');
require('dotenv').config()

const commands = [{
    name: 'ping',
    description: 'Replies with gnome server status!',
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
      description: 'top up number (1 - 12)',
      type: 4,
      required: true
    }, {
      name: 'multiplication',
      description: 'pick multiplication 1 - 20',
      type: 4,
      required: true
    }]
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