defmodule ParserTest do
  use ExUnit.Case

  test "Check Basic Parser" do
    rss_data = """
    <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
    <channel>
      <atom:link href="https://nitter.privacydev.net/JCParking/rss" rel="self" type="application/rss+xml" />
      <title>JCParking / @JCParking</title>
      <link>https://nitter.privacydev.net/JCParking</link>
      <description>Twitter feed for: @JCParking. Generated by nitter.privacydev.net</description>
      <language>en-us</language>
      <ttl>40</ttl>
      <image>
        <title>JCParking / @JCParking</title>
        <link>https://nitter.privacydev.net/JCParking</link>
        <url>https://nitter.privacydev.net/pic/pbs.twimg.com%2Fprofile_images%2F672096120659697664%2FvYDLqbNd_400x400.jpg</url>
        <width>128</width>
        <height>128</height>
      </image>
        <item>
          <title>Alternate side of the street parking (street sweeping) is suspended Tuesday and Wednesday, February 11-12, 2025. Enforcement regulations will resume the next day.</title>
          <dc:creator>@JCParking</dc:creator>
          <description><![CDATA[<p>Alternate side of the street parking (street sweeping) is suspended Tuesday and Wednesday, February 11-12, 2025. Enforcement regulations will resume the next day.</p>
          <img src="https://nitter.privacydev.net/pic/media%2FGjgVNu8XIAA6Uto.jpg" style="max-width:250px;" />]]></description>
          <pubDate>Tue, 11 Feb 2025 12:00:31 GMT</pubDate>
          <guid>https://nitter.privacydev.net/JCParking/status/1889283372192514151#m</guid>
          <link>https://nitter.privacydev.net/JCParking/status/1889283372192514151#m</link>
        </item>
      </channel>
      </rss>
    """

    assert Parser.get_data(rss_data) ==
             {:ok,
              [
                %{
                  "author" => "@JCParking",
                  "content" =>
                    "Alternate side of the street parking (street sweeping) is suspended Tuesday and Wednesday, February 11-12, 2025. Enforcement regulations will resume the next day.",
                  "publish_timestamp" => ~U[2025-02-11 12:00:31Z],
                  "post_id" => "JCParking_1889283372192514151"
                }
              ]}
  end

  test "Check 2 item string with basic parser" do
    rss_data = """
    <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
    <channel>
      <atom:link href="https://nitter.privacydev.net/JCParking/rss" rel="self" type="application/rss+xml" />
      <title>JCParking / @JCParking</title>
      <link>https://nitter.privacydev.net/JCParking</link>
      <description>Twitter feed for: @JCParking. Generated by nitter.privacydev.net</description>
      <language>en-us</language>
      <ttl>40</ttl>
      <image>
        <title>JCParking / @JCParking</title>
        <link>https://nitter.privacydev.net/JCParking</link>
        <url>https://nitter.privacydev.net/pic/pbs.twimg.com%2Fprofile_images%2F672096120659697664%2FvYDLqbNd_400x400.jpg</url>
        <width>128</width>
        <height>128</height>
      </image>
        <item>
          <title>Alternate side of the street parking (street sweeping) is suspended Tuesday and Wednesday, February 11-12, 2025. Enforcement regulations will resume the next day.</title>
          <dc:creator>@JCParking</dc:creator>
          <description><![CDATA[<p>Alternate side of the street parking (street sweeping) is suspended Tuesday and Wednesday, February 11-12, 2025. Enforcement regulations will resume the next day.</p>
          <img src="https://nitter.privacydev.net/pic/media%2FGjgVNu8XIAA6Uto.jpg" style="max-width:250px;" />]]></description>
          <pubDate>Tue, 11 Feb 2025 12:00:31 GMT</pubDate>
          <guid>https://nitter.privacydev.net/JCParking/status/1889283372192514151#m</guid>
          <link>https://nitter.privacydev.net/JCParking/status/1889283372192514151#m</link>
        </item>
        <item>
        <title>Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.</title>
        <dc:creator>@JCParking</dc:creator>
        <description><![CDATA[<p>Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.</p>
        <img src="https://nitter.privacydev.net/pic/media%2FGjbLmsPXoAAMbmt.jpg" style="max-width:250px;" />]]></description>
        <pubDate>Mon, 10 Feb 2025 12:00:26 GMT</pubDate>
        <guid>https://nitter.privacydev.net/JCParking/status/1888920962810195985#m</guid>
        <link>https://nitter.privacydev.net/JCParking/status/1888920962810195985#m</link>
      </item>
      </channel>
      </rss>
    """

    assert Parser.get_data(rss_data) ==
             {:ok,
              [
                %{
                  "author" => "@JCParking",
                  "content" =>
                    "Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.",
                  "publish_timestamp" => ~U[2025-02-10 12:00:26Z],
                  "post_id" => "JCParking_1888920962810195985"
                },
                %{
                  "author" => "@JCParking",
                  "content" =>
                    "Alternate side of the street parking (street sweeping) is suspended Tuesday and Wednesday, February 11-12, 2025. Enforcement regulations will resume the next day.",
                  "publish_timestamp" => ~U[2025-02-11 12:00:31Z],
                  "post_id" => "JCParking_1889283372192514151"
                }
              ]}
  end
end
