const pino = require("pino");

const logger = pino({
  level: process.env.LOG_LEVEL || "debug",
  transport: {
    target: "pino-pretty",
    options: {
      colorize: true,
      translateTime: "SYS:HH:MM:ss",
      ignore: "pid,hostname",
      messageFormat: "{msg}",
    },
  },
});

module.exports = logger;
