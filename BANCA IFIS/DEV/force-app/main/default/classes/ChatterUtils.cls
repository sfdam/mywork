public with sharing class ChatterUtils {

  public static ConnectApi.FeedItemInput createPostChatter(Id oggetto, Id menzione, String messaggio) {
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

    mentionSegmentInput.id = menzione;
    messageBodyInput.messageSegments.add(mentionSegmentInput);

    textSegmentInput.text = ' ' + messaggio;
    messageBodyInput.messageSegments.add(textSegmentInput);

    feedItemInput.body = messageBodyInput;
    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    feedItemInput.subjectId = oggetto;

    return feedItemInput;
  }

  public static ConnectApi.FeedItemInput createPostChatterMenzione(Id oggetto, Id menzione, String messaggio) {
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
    ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();

    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    String[] messaggioSplitted = messaggio.split('%menzione%');

    textSegmentInput1.text = ' ' + messaggioSplitted[0];
    messageBodyInput.messageSegments.add(textSegmentInput1);

    mentionSegmentInput.id = menzione;
    messageBodyInput.messageSegments.add(mentionSegmentInput);

    textSegmentInput2.text = ' ' + messaggioSplitted[1];
    messageBodyInput.messageSegments.add(textSegmentInput2);

    feedItemInput.body = messageBodyInput;

    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    feedItemInput.subjectId = oggetto;

    return feedItemInput;
  }

  public static void postToChatter(Id oggetto, Id menzione, String messaggio) {
    ConnectApi.FeedItemInput feedItemInput = ChatterUtils.createPostChatter(oggetto, menzione, messaggio);
    ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
  }

  /**
   * Possibilita di inserire nel messaggio %mezione%, per determinare dove apparirà.
   */
  public static void postToChatterMenzione(Id oggetto, Id menzione, String messaggio) {
    ConnectApi.FeedItemInput feedItemInput = ChatterUtils.createPostChatterMenzione(oggetto, menzione, messaggio);
    ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
  }

  public static void postToChatterBatch(ConnectApi.FeedItemInput[] feedItemInputs) {
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    for (ConnectApi.FeedItemInput fii : feedItemInputs) {
      batchInputs.add(new ConnectApi.BatchInput(fii));
    }
    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
  }
}