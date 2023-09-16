// See https://aka.ms/new-console-template for more information


using Nerdbank.Streams;
using StreamJsonRpc;
using Newtonsoft.Json;


public class MyJsonRpcService
{
    public string Ping(string ping) => $"Pong: {ping}";


    private static Discord.Discord discord;
    private static Discord.ActivityManager activityManager;
    public string RemoveRP(string json) => RemoveRPFunc(json);

    static string RemoveRPFunc(string data)
    {
        string callbackMSG = "OK";
        activityManager.ClearActivity((res) =>
        {

            Console.WriteLine(res);
            if (res != Discord.Result.Ok) callbackMSG = "Failed connecting to Discord!";
        });
        return callbackMSG;
    }

    public string SetRP(string data) => SetRPFunc(data);
    static string SetRPFunc(string json)
    {
        string callbackMSG = "OK";



        var activity = JsonConvert.DeserializeObject<Discord.Activity>(json);

        activityManager.UpdateActivity(activity, (res) =>
        {

            Console.WriteLine(res);
            if (res != Discord.Result.Ok) callbackMSG = "Failed connecting to Discord!";
        });
        return callbackMSG;
    }

    static async Task Main(string[] args)
    {

        if (args.Length < 1)
        {
            Console.WriteLine("No appID provided! Exiting!");
            System.Environment.Exit(-1);
        }
        try
        {
            var appID = args[0];
            long.TryParse(appID, out long zahlAlsLong);
            discord = new Discord.Discord(zahlAlsLong, (UInt64)Discord.CreateFlags.Default);
            activityManager = discord.GetActivityManager();
        }
        catch
        {
            Console.WriteLine("No appID provided! Exiting!");
            System.Environment.Exit(-1);
        }
        Timer timer = new Timer(TimerCallback, null, 0, 500); // TimerCallback will be called every 500ms (0.5 second)
        discord.SetLogHook(Discord.LogLevel.Debug, (level, message) =>
        {
            Console.WriteLine(level + message);
        });


        Console.WriteLine(discord);

        Console.WriteLine(activityManager);

        activityManager.OnActivityJoinRequest += (ref Discord.User user) =>
        {
            activityManager.SendInvite(userId: user.Id, content: "du hast gfragt", type: Discord.ActivityActionType.Join
            , callback: (e) =>
        {
            Console.WriteLine(e);
        });
        };
        Console.WriteLine("Hello World!");
        var stream = FullDuplexStream.Splice(
          Console.OpenStandardInput(),
          Console.OpenStandardOutput()
        );
        var server = new MyJsonRpcService(); //<-change this
        using var jsonRpc = JsonRpc.Attach(stream, server);
        await jsonRpc.Completion;


    }

    private static void TimerCallback(object state)
    {
        // Your function code here
        discord.RunCallbacks();
    }

}

