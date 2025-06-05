using SharpToken;
var txt = args.Length == 0 ? Console.In.ReadToEnd() : File.ReadAllText(args[0]);
var enc = GptEncoding.GetEncoding("cl100k_base");
Console.WriteLine($"Token count: {enc.Encode(txt).Count}");
