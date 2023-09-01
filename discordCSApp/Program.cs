// See https://aka.ms/new-console-template for more information


using Nerdbank.Streams;
using StreamJsonRpc;
using Newtonsoft.Json;


public class MyJsonRpcService
{
    public string Ping(string ping) => $"Pong: {ping}";


    private static Discord.Discord discord = new Discord.Discord(1143558810200461372, (UInt64)Discord.CreateFlags.Default);
    private static Discord.ActivityManager activityManager = discord.GetActivityManager();
    public string RemoveRP(string json) => RemoveRPFunc(json);

    static string RemoveRPFunc(string data)
    {
        string callbackMSG = "";
        activityManager.ClearActivity((res) =>
        {

            Console.WriteLine(res);
            if (res != Discord.Result.Ok) callbackMSG = "Failed connecting to Discord!";
        });
        return callbackMSG;
    }

    public string SetRP(string data) => SetRPFunc(data);
    static string SetRPFunc(string data)
    {
        string callbackMSG = "OK";

        var json = "{'Details':'Hello from C#','State':'Playing with Megulicious','Timestamps':{'Start':1672533067},'Assets':{'LargeImage':'test','LargeText':'ancientxfire','SmallImage':'test','SmallText':'smol'},'Secrets':{'Match':'ae488379-351d-4a4f-ad32-2b9b01c91657-2','Join':'MTI4NzM0OjFpMmhuZToxMjMxMjM='},'Party':{'Id':'ae488379-351d-4a4f-ad32-2b9b01c91657','Size':{'CurrentSize':10,'MaxSize':100},'Privacy':2}}";

        var activity = JsonConvert.DeserializeObject<Discord.Activity>(json);
        activityManager.OnActivityJoinRequest += (ref Discord.User user) =>
        {
            activityManager.SendInvite(userId: user.Id, content: "du hast gfragt", type: Discord.ActivityActionType.Join
            , callback: (e) =>
        {
            Console.WriteLine(e);
        });
        };

        activityManager.UpdateActivity(activity, (res) =>
        {

            Console.WriteLine(res);
            if (res != Discord.Result.Ok) Console.WriteLine("Failed connecting to Discord!");
        });
        activityManager.UpdateActivity(activity, (res) =>
        {

            Console.WriteLine(res);
            if (res != Discord.Result.Ok) callbackMSG = "Failed connecting to Discord!";
        });
        return callbackMSG;
    }

    static async Task Main(string[] args)
    {
        Timer timer = new Timer(TimerCallback, null, 0, 500); // TimerCallback will be called every 500ms (0.5 second)

        // Keep the program running until the user presses a key


        discord.SetLogHook(Discord.LogLevel.Debug, (level, message) =>
        {
            Console.WriteLine(level + message);
        });


        Console.WriteLine(discord);

        Console.WriteLine(activityManager);


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

