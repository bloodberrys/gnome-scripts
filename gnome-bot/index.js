/**
 * @file Manages the functionalities of Gnome Tools Discord Automation.
 * @author Alfian Firmansyah <alfianvansykes@gmail.com>
 */

const axios = require('axios');
const FormData = require('form-data');

const {
  Client,
  GatewayIntentBits,
  EmbedBuilder,
  ActivityType
} = require('discord.js');

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent],
  partials: ['CHANNEL']
});
require('dotenv').config()

client.on('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`);

  // Activity Set
  client.user.setPresence({
    activities: [{
      name: `gnome kingdom`,
      type: ActivityType.Watching // Competing, Custom, Listening, Playing, Streaming, Watching
    }],
    status: 'online', // dnd, idle, invisible, offline, online
  });

  // Getting the channel from client.channels Collection. #gnome-bot-development
  const Channel = client.channels.cache.get("1052705588628426782");

  // Checking if the channel exists.
  if (!Channel) return console.error("Couldn't find the channel.");

  // Sending log active to the private channel.
  // Channel.send(`Bot <@${client.user.id}> is now active/restarted.`).catch(e => console.log(e));
});


/**
 * Auto Responder Message
 */
client.on("messageCreate", (message) => {
  if (message.mentions.has(client.user)) {
    message.reply("Are you gonna be kidding me? Please leave me alone!");
  }

  switch (message.content) {
    case 'morning':
    case 'Morning':
    case 'Good morning':
    case 'good morning':
      if (message.author.id === '700907087529639937') {
        message.channel.send(`Hi... Good morning boss <@${message.author.id}>!\nHave a nice day.`);
        return;
      }
      message.channel.send(`Hi... Good morning <@${message.author.id}>!\nHave a nice day~`)
      break;

    case 'night':
    case 'Night':
    case 'Good night':
    case 'good night':
      message.channel.send(`Hi... Good night <@${message.author.id}>!\nHave a nice dream.`)
      break;
    default:

  }


});


client.on('interactionCreate', async interaction => {

  // pre Checks
  if (!interaction.isChatInputCommand()) return;

  // only by administrator for executing the slash command
  if (!interaction.memberPermissions.has('Administrator')) {
    var userId = interaction.user.id
    console.log(`User prohibited found: <@${userId}>`)
    await interaction.reply(`You <@${userId}> have sufficient permission to send a slash command! Your identity will be recorded as per our security procedure to be evaluated. Thank you`);
  }

  // Commands by user
  switch (interaction.commandName) {
    case 'ping':
      const pingEmbed = new EmbedBuilder()
        .setColor("#0099ff")
        .setTitle("Pong")
        .setDescription(`🏓 Latency is ${Date.now() - interaction.createdTimestamp}ms. \n⏰ API Latency is ${Math.round(client.ws.ping)}ms`);

      await interaction.reply({
        embeds: [pingEmbed]
      });
      break;
    case 'tplist':
      const topupListEmbed = new EmbedBuilder()
        .setColor(0x0099FF)
        .setTitle('Gnome Top-up List')
        .setURL('https://forms.gle/deYEkwuUfqpoPHHA9')
        // .setAuthor({
        //   name: 'Christmas Argenta',
        //   iconURL: 'https://i.imgur.com/AfFp7pu.png',
        //   url: 'https://discord.js.org'
        // })
        .setDescription('Some description here')
        .setThumbnail('https://cdn-longterm.mee6.xyz/plugins/embeds/images/982965984925200404/f857cd3669f42d50358a0ef74a275676fb1827865adf3fe859028156383da2b9.png')
        .addFields({
          name: 'Regular field title',
          value: 'Some value here'
        }, {
          name: '\u200B',
          value: '\u200B'
        }, {
          name: 'Inline field title',
          value: 'Some value here',
          inline: true
        }, {
          name: 'Inline field title',
          value: 'Some value here',
          inline: true
        }, )
        .addFields({
          name: 'Inline field title',
          value: 'Some value here',
          inline: true
        })
        // .setImage('https://i.imgur.com/AfFp7pu.png')
        .setTimestamp()
        .setFooter({
          text: 'Gnome Treasury Automation',
          iconURL: 'https://s3.ap-southeast-1.amazonaws.com/gnome-hub.com/gnome-email-1/images/1355900.png'
        });

      await interaction.reply({
        embeds: [topupListEmbed]
      });
      break;
    case 'tpsend':
      const uid = interaction.options.getInteger('uid');
      const topUpNumber = interaction.options.getInteger('top-up-number');
      const multiplication = interaction.options.getInteger('multiplication');

      var bodyFormData = new FormData();

      bodyFormData.append('uid', '4');

      // Conditional for top up number can be built here
      bodyFormData.append('multi_item', '1');

      // multiplication will also follow the top up number baseline
      bodyFormData.append('multi_num', '1000');
      bodyFormData.append('title', 'Testing Discord Command');
      bodyFormData.append('message', 'Testing Message');


      await axios({
          method: "post",
          url: "http://obt.gnome-hub.com:81/Hd487azwflCapcapcap123-@/api.php",
          data: bodyFormData,
          headers: {
            "Content-Type": "multipart/form-data"
          },
        })
        .then(function (response) {
          //handle success
          interaction.reply(`Top-up sent and success!\nUID: ${uid}, topup number: ${topUpNumber}, multiplication: ${multiplication}\n\nResponse Code: ${response.status} ${response.statusText}\nResponse Data: ${response.data}\nDate: ${response.headers.date}`)
          console.log(response);
        })
        .catch(function (response) {
          //handle error
          interaction.reply(`Error: ${response}`)
          console.log(response);
        });

      break;
    default:
      // code block
  }

});

client.on("unhandledRejection", async (err) => {
  console.error("Unhandled Promise Rejection:\n", err);
});

client.login(process.env.TOKEN);