/**
 * @file index.js Manages the functionalities of Gnome Tools Discord Automation.
 * @author Alfian Firmansyah <alfianvansykes@gmail.com>
 * @version 1.0
 * @see https://discord.gg/dnmgnome
 */

import request from 'request';
import {
  readFileSync
} from 'fs';

import {
  Client,
  GatewayIntentBits,
  EmbedBuilder,
  ActivityType
} from 'discord.js';

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent],
  partials: ['CHANNEL']
});

import createConversationJSON from './spreadsheet.js';
import registerCommand from './register-command.js';
import randomizeAnswer from './randomize-dupe-answer.js';

import dotenv from 'dotenv'
dotenv.config()

client.on('ready', () => {
  registerCommand();
  createConversationJSON();
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
  Channel.send(`I'm active/restarted by boss <@700907087529639937>!`).catch(e => console.log(e));
});


/**
 * Auto Responder Message
 */
client.on("messageCreate", (message) => {
  if (message.author.bot) return;

  if (message.mentions.has(client.user) && !message.content.includes("@here") && !message.content.includes("@everyone")) {
    message.reply("Whatsup? Are you gonna be kidding me? Please leave me alone!");
  }

  // AUTO RESPONDER LEARNING: greeting or curse word.
  // Take top up mapping conversation payload data from json
  let conversationRaw = readFileSync('json_database/conversation.json');
  let conversation = JSON.parse(conversationRaw);

  var allWordDatabase = []
  for (let i = 0; i < conversation.length; i++) {
    allWordDatabase.push(conversation[i].question)
  }

  // word rule data in allWordDatabase
  var evaluatedWord = allWordDatabase
  console.log("[LOAD WORD FROM JSON DATABASE...]")

  // all message content from discord user to lower case
  var content = message.content.toLocaleLowerCase();

  function findWord(content, str) {
    return RegExp('\\b' + str.replace(/[^a-zA-Z ]/g, " ") + '\\b').test(content.replace(/[^a-zA-Z ]/g, " "))
  }

  var result = []

  console.log(`[CONTENT STRING SYMBOL CLEANING PROCESS...]`)
  for (let j = 0; j < evaluatedWord.length; j++) {
    if (findWord(content, evaluatedWord[j])) {
      result.push(evaluatedWord[j])
      console.log(`[MATCH PROCESS][IDENTIFICATION] ${j+1} Content: ${content} | Database: ${evaluatedWord[j]}`)
    }
  }

  // clean duplicated arrays
  let wordEvaluatedResult = [...new Set(result)];
  console.log(`[MATCH PROCESS][UNSHUFFLED] Found the match word result from database: ${wordEvaluatedResult}`);
  // Shuffle it
  wordEvaluatedResult = wordEvaluatedResult
    .map(value => ({
      value,
      sort: Math.random()
    }))
    .sort((a, b) => a.sort - b.sort)
    .map(({
      value
    }) => value)
  console.log(`[MATCH PROCESS][SHUFFLED] Found the match word result from database: ${wordEvaluatedResult}`);

  // get the answer and send it
  for (let j = 0; j < wordEvaluatedResult.length; j++) {
    // Shuffle the answer by randomize the object or array
    let answer = randomizeAnswer(conversation, wordEvaluatedResult[j])
    console.log(`[ANSWER RANDOMIZER PROCESS...] ${j+1} Answer to be sent: ${answer}`)
    // let answer = conversation.find(x => x.question === String(wordEvaluatedResult[j])).answer;
    message.reply(`${answer}`)
    return;
  }

  switch (message.content.toLocaleLowerCase()) {
    case 'morning':
    case 'good morning':
      if (message.author.id === '700907087529639937') {
        message.channel.send(`Hi... Good morning boss <@${message.author.id}>!\nHave a nice day.`);
        return;
      }
      message.channel.send(`Hi... Good morning <@${message.author.id}>!\nHave a nice day~`)
      break;

    case 'night':
    case 'Good night':
      message.channel.send(`Hi... Good night <@${message.author.id}>!\nHave a nice dream.`)
      break;
    default:

  }


});


client.on('interactionCreate', async interaction => {

  // pre Checks
  if (!interaction.isChatInputCommand()) return;

  var userId = interaction.user.id

  // only by administrator for executing the slash command
  if (!interaction.memberPermissions.has('Administrator')) {
    console.log(`User prohibited found: <@${userId}>`)
    await interaction.reply(`You <@${userId}> have insufficient permission to send a slash command! Your identity will be recorded as per our security procedure to be evaluated. Thank you`);
    return;
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
    case 'help':
      const helpEmbed = new EmbedBuilder()
        .setColor("#0099ff")
        .setTitle("What can I do for you? Here is the thing that you can do:")
        .setDescription(`Slash Commands available:\n\n\`/ping\` - To know the bot is ready or not to take an action, please use this before you send the top up.\n\`/tplist\` - To know what is the available top up number\n\`/tpsend\` - To send the top-up using the arguments (uid, top-up-number, multiplication, and bonus x2)`);

      await interaction.reply({
        embeds: [helpEmbed]
      });
      break;
    case 'tplist':

      let rawdata = readFileSync('topuplist.json');
      let topupListData = JSON.parse(rawdata);

      const topupListEmbed = new EmbedBuilder()
        .setColor(0x0099FF)
        .setTitle('Gnome Top-up List')
        .setURL('https://forms.gle/deYEkwuUfqpoPHHA9')
        .setDescription('Gnome top-up/donation lists:')
        .setThumbnail('https://cdn-longterm.mee6.xyz/plugins/embeds/images/982965984925200404/f857cd3669f42d50358a0ef74a275676fb1827865adf3fe859028156383da2b9.png')
        .addFields(topupListData)
        .setTimestamp()
        .setFooter({
          text: 'Gnome Treasury Automation',
          iconURL: 'https://s3.ap-southeast-1.amazonaws.com/gnome-hub.com/gnome-email-1/images/1355900.png'
        });

      await interaction.reply({
        embeds: [topupListEmbed]
      });
      console.log("tplist command executed")
      break;
    case 'tpsend':
      const uid = interaction.options.getInteger('uid');
      const topUpNumber = interaction.options.get('top-up-number').value;
      const multiplication = interaction.options.get('multiplication').value;
      const confirm = interaction.options.get('confirm').value;
      const isFirstBonus = interaction.options.get('is-first-bonus') !== null ? interaction.options.get('is-first-bonus').value : 0;

      console.log(typeof topUpNumber)
      console.log(typeof multiplication)
      console.log(typeof confirm)
      console.log(isFirstBonus)

      // Take top up mapping payload data from json
      let payloadData = readFileSync('topup-item-payload.json');
      let topupPayloadData = JSON.parse(payloadData);

      function getTopupByNumber(topupNum) {
        return topupPayloadData.filter(
          function (topupPayloadData) {
            return topupPayloadData.value == topupNum
          }
        );
      }

      if (confirm === 0) {
        console.log("Top up cancelled")
        interaction.reply(`You cancel the top up lah, what happen?`)
        return;
      }

      // handler for top up number doesn't exist
      if (getTopupByNumber(topUpNumber) == false) {
        console.log("top up number doesn't exit")
        interaction.reply(`The number of top up list \`${topUpNumber}\` doesn't exist at all, why are you so weird.\n\nPlease input 1 - 12 top up number based on \`/tplist\` command.`)
        return;
      }

      // find from the json mapping
      let name = topupPayloadData.find(x => x.value === String(topUpNumber)).name;
      let itemId = topupPayloadData.find(x => x.value === String(topUpNumber)).itemId;
      let qty = topupPayloadData.find(x => x.value === String(topUpNumber)).qty;
      let isBonus = topupPayloadData.find(x => x.value === String(topUpNumber)).bonus;


      // multiplication validation
      if (multiplication > 20 || multiplication < 1) {
        await interaction.reply(`Your multiplication input: \`${multiplication}\` have exceeded the multiplication number, please retry with 1 - 20 instead`);
        return;
      }

      // count multiplication and convert to string
      // For multiple item and qty
      if (multiplication > 1 && typeof qty === 'object') {
        qty = qty.map(Number);
        qty = qty.map(x => x * multiplication)

        // First top up Bonus quantification
        if (isFirstBonus === 1 && isBonus === true) {
          // bonus x2
          qty = qty.map(x => x * 2)
          console.log("First bonus is executed for multiple value")
        }
      } else if (multiplication > 1 && typeof qty === 'string') { // for single item and qty
        qty = Number(qty);
        qty = qty * multiplication;

        // First top up Bonus quantification
        if (isFirstBonus === 1 && isBonus === true) {
          // bonus x2
          qty = qty * 2
          console.log("First bonus is executed for single")
        }
      }

      // convert object to string to support the sending payload
      let title = 'Successful Purchase!';
      let message = 'Thank you for purchasing in our Top-up Shop!\\n\\nFor kingdom privilege, will be applied on the next reset. We hope you like the item, have fun and enjoy~';
      itemId = itemId.toString()
      qty = qty.toString()

      // UID GUARD FOR TESTING
      if (uid > 10) {
        console.log("UID GUARD is executed")
        interaction.reply("Uh Oh, this feature is still under testing, please use UID below 10 for testing.");
        return;
      }

      // logging purpose debugging
      console.log(`UID: ${uid}`)
      console.log(`Item ID: ${typeof itemId}`)
      console.log(`Item ID: ${itemId}`)
      console.log(`QTY: ${typeof qty}`)
      console.log(`QTY: ${qty}`)

      let firstBonusStringActive = '✅'
      let firstBonusStringNotActive = '❌'
      let firstBonusString = ''

      // First bonus status
      if (isFirstBonus === 1 && isBonus === true)
        firstBonusString = firstBonusStringActive
      else
        firstBonusString = firstBonusStringNotActive

      console.log(`First Bonus: ${firstBonusString}`)

      var data = {
        'uid': uid,
        'multi_item': itemId,
        'multi_num': qty,
        'title': title,
        'message': message,
        'executor': userId
      }

      console.log(data)

      var options = {
        'method': 'POST',
        'url': process.env.TOPUP_ENDPOINT_API,
        'headers': {
          "Content-Type": "multipart/form-data"
        },
        formData: data
      };
      request(options, function (error, response) {

        // handle error
        if (error) {
          interaction.reply(`❌ Top-up fatal Error ❌\n${error}`)
          return console.error(`\nExecuted by <@${userId}> topup fatal error:`, error);
        }

        //handle success
        let string = ''
        if (response.body)
          string = response.body;

        if (string.includes("Failed") === true || string.includes("Not Found") === true) {
          interaction.reply(`**❌ Top-up failed with Error ❌**\nExecuted by <@${userId}>\n\nUID: \`${uid}\`\nTopuplist: ${name}\nMultiplication: \`${multiplication}\`\nFirst Topup Bonus x2: ${firstBonusString}\nTotal QTY: \`${qty}\`\n\n\`\`\`\nStatusCode: ${response.statusCode} ${response.statusMessage}\nResponse Data: ${response.body}\nDate: ${response.headers['date']}\n\`\`\``)
          // console.log(response.body);
          return;
        }
        interaction.reply(`**✅ Top-up sent and success! ✅**\nExecuted by <@${userId}>\n\nUID: \`${uid}\`\nTopuplist: ${name}\nMultiplication: \`${multiplication}\`\nFirst Topup Bonus x2: ${firstBonusString}\nTotal QTY: \`${qty}\`\n\n\`\`\`\nStatusCode: ${response.statusCode} ${response.statusMessage}\nResponse Data: ${response.body}\nDate: ${response.headers['date']}\n\`\`\``)
        // console.log(response.body);

      });

      break;
    case 'rsend':
      sendReward(interaction, 'Christmas share event', 'share-event.json', 'Christmas Share Event Rewards', "Thanks for your participation in christmas share event. Wish you a merry christmas and a happy new year. Let's have fun together!\n\nGnome")
      break;
    default:
      // code block
  }

});

client.on("unhandledRejection", async (err) => {
  console.error("Unhandled Promise Rejection:\n", err);
});


async function startGracefulShutdown() {
  console.log('Starting shutdown of bot...');
  const channelID = '1052705588628426782';
  const channel = client.channels.cache.get(channelID);
  await channel.send("Ouch, something hit me, It shutted me down, I died help!\n\nSIGTERM/SIGINT signal from the machine <@&984895894203805746> <@&983558291261112370>.\n PLEASE WAKE ME UP SOON using pm2!\n\n\`\`\`\ncd /home/<ec2-user/centos>/gnome-scripts/gnome-bot/\nnvm use 16\npm2 list\npm2 start index.js\n\`\`\`");
  return process.exit();
}

async function sendReward(interaction, rewardName = 'Top-up', payload = 'topup-item-payload.json', title = '', message = '') {
  const uid = interaction.options.getInteger('uid');
  const topUpNumber = interaction.options.get('top-up-number').value;
  const multiplication = interaction.options.get('multiplication').value;
  const confirm = interaction.options.get('confirm').value;
  const isFirstBonus = interaction.options.get('is-first-bonus') !== null ? interaction.options.get('is-first-bonus').value : 0;

  console.log(typeof topUpNumber)
  console.log(typeof multiplication)
  console.log(typeof confirm)
  console.log(isFirstBonus)

  // Take top up mapping payload data from json
  let payloadData = readFileSync(payload);
  let topupPayloadData = JSON.parse(payloadData);

  function getTopupByNumber(topupNum) {
    return topupPayloadData.filter(
      function (topupPayloadData) {
        return topupPayloadData.value == topupNum
      }
    );
  }

  if (confirm === 0) {
    console.log("Top up cancelled")
    interaction.reply(`You cancel the top up lah, what happen?`)
    return;
  }

  // handler for top up number doesn't exist
  if (getTopupByNumber(topUpNumber) == false) {
    console.log("top up number doesn't exit")
    interaction.reply(`The number of top up list \`${topUpNumber}\` doesn't exist at all, why are you so weird.\n\nPlease input 1 - 12 top up number based on \`/tplist\` command.`)
    return;
  }

  // find from the json mapping
  let name = topupPayloadData.find(x => x.value === String(topUpNumber)).name;
  let itemId = topupPayloadData.find(x => x.value === String(topUpNumber)).itemId;
  let qty = topupPayloadData.find(x => x.value === String(topUpNumber)).qty;
  let isBonus = topupPayloadData.find(x => x.value === String(topUpNumber)).bonus;


  // multiplication validation
  if (multiplication > 20 || multiplication < 1) {
    await interaction.reply(`Your multiplication input: \`${multiplication}\` have exceeded the multiplication number, please retry with 1 - 20 instead`);
    return;
  }

  // count multiplication and convert to string
  // For multiple item and qty
  if (multiplication > 1 && typeof qty === 'object') {
    qty = qty.map(Number);
    qty = qty.map(x => x * multiplication)

    // First top up Bonus quantification
    if (isFirstBonus === 1 && isBonus === true) {
      // bonus x2
      qty = qty.map(x => x * 2)
      console.log("First bonus is executed for multiple value")
    }
  } else if (multiplication > 1 && typeof qty === 'string') { // for single item and qty
    qty = Number(qty);
    qty = qty * multiplication;

    // First top up Bonus quantification
    if (isFirstBonus === 1 && isBonus === true) {
      // bonus x2
      qty = qty * 2
      console.log("First bonus is executed for single")
    }
  }

  // convert object to string to support the sending payload
  // let title = 'Successful Purchase!';
  // let message = 'Thank you for purchasing in our Top-up Shop!\\n\\nFor kingdom privilege, will be applied on the next reset. We hope you like the item, have fun and enjoy~';
  itemId = itemId.toString()
  qty = qty.toString()

  // UID GUARD FOR TESTING
  // if (uid > 10) {
  //   console.log("UID GUARD is executed")
  //   interaction.reply("Uh Oh, this feature is still under testing, please use UID below 10 for testing.");
  //   return;
  // }

  // logging purpose debugging
  console.log(`UID: ${uid}`)
  console.log(`Item ID: ${typeof itemId}`)
  console.log(`Item ID: ${itemId}`)
  console.log(`QTY: ${typeof qty}`)
  console.log(`QTY: ${qty}`)

  let firstBonusStringActive = '✅'
  let firstBonusStringNotActive = '❌'
  let firstBonusString = ''

  // First bonus status
  if (isFirstBonus === 1 && isBonus === true)
    firstBonusString = firstBonusStringActive
  else
    firstBonusString = firstBonusStringNotActive

  console.log(`First Bonus: ${firstBonusString}`)

  var data = {
    'uid': uid,
    'multi_item': itemId,
    'multi_num': qty,
    'title': title,
    'message': message,
    'executor': userId
  }

  console.log(data)

  var options = {
    'method': 'POST',
    'url': process.env.TOPUP_ENDPOINT_API,
    'headers': {
      "Content-Type": "multipart/form-data"
    },
    formData: data
  };
  request(options, function (error, response) {

    // handle error
    if (error) {
      interaction.reply(`❌ ${rewardName} fatal Error ❌\n${error}`)
      return console.error(`\nExecuted by <@${userId}> topup fatal error:`, error);
    }

    //handle success
    let string = ''
    if (response.body)
      string = response.body;

    if (string.includes("Failed") === true || string.includes("Not Found") === true) {
      interaction.reply(`**❌ ${rewardName} failed with Error ❌**\nExecuted by <@${userId}>\n\nUID: \`${uid}\`\nTopuplist: ${name}\nMultiplication: \`${multiplication}\`\nFirst Topup Bonus x2: ${firstBonusString}\nTotal QTY: \`${qty}\`\n\n\`\`\`\nStatusCode: ${response.statusCode} ${response.statusMessage}\nResponse Data: ${response.body}\nDate: ${response.headers['date']}\n\`\`\``)
      // console.log(response.body);
      return;
    }
    interaction.reply(`**✅ ${rewardName} sent and success! ✅**\nExecuted by <@${userId}>\n\nUID: \`${uid}\`\nTopuplist: ${name}\nMultiplication: \`${multiplication}\`\nFirst Topup Bonus x2: ${firstBonusString}\nTotal QTY: \`${qty}\`\n\n\`\`\`\nStatusCode: ${response.statusCode} ${response.statusMessage}\nResponse Data: ${response.body}\nDate: ${response.headers['date']}\n\`\`\``)
    // console.log(response.body);

  });
}

client.login(process.env.TOKEN);

process.on('SIGTERM', startGracefulShutdown);
process.on('SIGINT', startGracefulShutdown);