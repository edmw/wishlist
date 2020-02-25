import Library

import Foundation

public enum Lorem {

    static let alphanumerics = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    public static func randomString() -> String {
        let count = Int.random(in: 8...16)
        return (0 ..< count).map { _ in String(alphanumerics.randomElement() ?? "?") }.joined()
    }

    public static func randomStrings(count: Int) -> [String] {
        return (0 ..< count).map { _ in randomString() }
    }

    public static func randomWord() -> String {
        return allWords.randomElement()!
    }

    public static func randomWords(count: Int) -> [String] {
        return (0 ..< count).map { _ in randomWord() }
    }

    public static func randomSentence() -> String {
        return compose(
            randomWord(),
            count: Int.random(in: 4...16),
            joinBy: .space,
            endWith: .dot,
            decorate: { $0.capitalizingFirstLetter() }
        )
    }

    public static func randomParagraph() -> String {
        return compose(
            randomSentence(),
            count: Int.random(in: 3...9),
            joinBy: .space
        )
    }

    public static func randomTitle() -> String {
        return compose(
            randomWord(),
            count: Int.random(in: 2...7),
            joinBy: .space,
            decorate: { $0.capitalized }
        )
    }

    public static func randomFirstName() -> String {
        return firstNames.randomElement()!
    }

    public static func randomLastName() -> String {
        return lastNames.randomElement()!
    }

    public static func randomURL() -> URL {
        let scheme = Bool.random() ? "http": "https"
        let domain = urlDomains.randomElement()!
        return URL(string: "\(scheme)://\(domain)")!
    }

    private enum Separator: String {
        case none = ""
        case space = " "
        case dot = "."
        case newline = "\n"
    }

    private static func compose(
        _ provider: @autoclosure () -> String,
        count: Int,
        joinBy separator: Separator,
        endWith endSeparator: Separator = .none,
        decorate decorator: ((String) -> String)? = nil
    ) -> String {
        let string = (0..<count)
            .map { _ in provider() }
            .joined(separator: separator.rawValue)
            .appending(endSeparator.rawValue)
        return (decorator ?? { string in return string })(string)
    }

    static let allWords = ["alias", "consequatur", "aut", "perferendis", "sit", "voluptatem", "accusantium", "doloremque", "aperiam", "eaque", "ipsa", "quae", "ab", "illo", "inventore", "veritatis", "et", "quasi", "architecto", "beatae", "vitae", "dicta", "sunt", "explicabo", "aspernatur", "aut", "odit", "aut", "fugit", "sed", "quia", "consequuntur", "magni", "dolores", "eos", "qui", "ratione", "voluptatem", "sequi", "nesciunt", "neque", "dolorem", "ipsum", "quia", "dolor", "sit", "amet", "consectetur", "adipisci", "velit", "sed", "quia", "non", "numquam", "eius", "modi", "tempora", "incidunt", "ut", "labore", "et", "dolore", "magnam", "aliquam", "quaerat", "voluptatem", "ut", "enim", "ad", "minima", "veniam", "quis", "nostrum", "exercitationem", "ullam", "corporis", "nemo", "enim", "ipsam", "voluptatem", "quia", "voluptas", "sit", "suscipit", "laboriosam", "nisi", "ut", "aliquid", "ex", "ea", "commodi", "consequatur", "quis", "autem", "vel", "eum", "iure", "reprehenderit", "qui", "in", "ea", "voluptate", "velit", "esse", "quam", "nihil", "molestiae", "et", "iusto", "odio", "dignissimos", "ducimus", "qui", "blanditiis", "praesentium", "laudantium", "totam", "rem", "voluptatum", "deleniti", "atque", "corrupti", "quos", "dolores", "et", "quas", "molestias", "excepturi", "sint", "occaecati", "cupiditate", "non", "provident", "sed", "ut", "perspiciatis", "unde", "omnis", "iste", "natus", "error", "similique", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollitia", "animi", "id", "est", "laborum", "et", "dolorum", "fuga", "et", "harum", "quidem", "rerum", "facilis", "est", "et", "expedita", "distinctio", "nam", "libero", "tempore", "cum", "soluta", "nobis", "est", "eligendi", "optio", "cumque", "nihil", "impedit", "quo", "porro", "quisquam", "est", "qui", "minus", "id", "quod", "maxime", "placeat", "facere", "possimus", "omnis", "voluptas", "assumenda", "est", "omnis", "dolor", "repellendus", "temporibus", "autem", "quibusdam", "et", "aut", "consequatur", "vel", "illum", "qui", "dolorem", "eum", "fugiat", "quo", "voluptas", "nulla", "pariatur", "at", "vero", "eos", "et", "accusamus", "officiis", "debitis", "aut", "rerum", "necessitatibus", "saepe", "eveniet", "ut", "et", "voluptates", "repudiandae", "sint", "et", "molestiae", "non", "recusandae", "itaque", "earum", "rerum", "hic", "tenetur", "a", "sapiente", "delectus", "ut", "aut", "reiciendis", "voluptatibus", "maiores", "doloribus", "asperiores", "repellat"]

    static let firstNames = ["Aaren", "Abigael", "Addi", "Adelice", "Adina", "Adriane", "Agace", "Agnese", "Ailee", "Aimee", "Alanah", "Aleece", "Alexa", "Alfreda", "Alie", "Alisun", "Allina", "Allys", "Aloysia", "Alys", "Amalee", "Amara", "Ameline", "Amye", "Anastasia", "Andrea", "Anet", "Angelika", "Anica", "Anna-Diane", "Annalee", "Annelise", "Annmarie", "Anthiathia", "April", "Ardeen", "Ardisj", "Ariel", "Arleta", "Arlyn", "Ashleigh", "Atalanta", "Aubrie", "Audy", "Aurelia", "Austina", "Avril", "Babs", "Barbee", "Basia", "Becka", "Belicia", "Bendite", "Berenice", "Bernelle", "Berrie", "Bertine", "Bethena", "Bettina", "Beverly", "Bidget", "Bird", "Blanch", "Blondelle", "Bobbye", "Bonny", "Breanne", "Bria", "Brigid", "Brit", "Britte", "Bryana", "Cacilia", "Calli", "Cami", "Candice", "Caren", "Carilyn", "Carleen", "Carlotta", "Carmelina", "Caro", "Caroline", "Carroll", "Cassandra", "Cate", "Cathi", "Catie", "Cecelia", "Celesta", "Celinda", "Chandra", "Charity", "Charmain", "Chelsea", "Cherida", "Cherry", "Chlo", "Christal", "Christie", "Chryste", "Cindi", "Clarabelle", "Clarie", "Claudette", "Clementine", "Clotilda", "Colleen", "Concordia", "Constantina", "Coralie", "Coreen", "Corina", "Cornelle", "Corrinne", "Crin", "Cristin", "Cybil", "Cynthie", "Dagmar", "Dalila", "Dani", "Danit", "Daphene", "Darcie", "Darleen", "Daryl", "Davida", "Deana", "Debi", "Deeann", "Del", "Delly", "Demetris", "Denys", "Devin", "Dian", "Didi", "Dionis", "Doe", "Dominga", "Donielle", "Doralynn", "Dorette", "Dorise", "Dorree", "Doti", "Drucie", "Dulcia", "Dyane", "Ealasaid", "Eddy", "Editha", "Eilis", "Elbertina", "Elenore", "Elicia", "Elissa", "Ellen", "Elna", "Elset", "Elvira", "Emalee", "Emili", "Emmaline", "Emogene", "Eolande", "Erinn", "Ernesta", "Essy", "Estrellita", "Ettie", "Eustacia", "Eveleen", "Evy", "Fanchon", "Farah", "Fawn", "Faythe", "Felisha", "Fernandina", "Filia", "Flo", "Florette", "Florry", "Francine", "Franny", "Frederique", "Gabbi", "Gabriellia", "Garnette", "Gaylene", "Genni", "Georgeta", "Geralda", "Germana", "Gertruda", "Gilberte", "Gilligan", "Giorgia", "Giulietta", "Glenn", "Glynda", "Goldina", "Grazia", "Grier", "Guinevere", "Gustie", "Gwennie", "Haily", "Hally", "Harley", "Harrietta", "Heather", "Hedy", "Helenka", "Henrieta", "Herta", "Hildagard", "Hollie", "Hortensia", "Ibby", "Ilene", "Imogen", "Ingaberg", "Iolanthe", "Isa", "Isobel", "Izabel", "Jacklyn", "Jacquenetta", "Jaimie", "Jandy", "Janenna", "Janie", "Janot", "Jayme", "Jeanie", "Jemima", "Jeniece", "Jennica", "Jerrie", "Jessamine", "Jewell", "Jillie", "Joanie", "Jobye", "Joeann", "Joete", "Jolee", "Jonell", "Jorie", "Josey", "Joyce", "Judy", "Julianne", "Julita", "Kacey", "Kaitlyn", "Kalinda", "Kania", "Karena", "Karisa", "Karlotte", "Karoly", "Kass", "Katee", "Katherina", "Kathy", "Katrine", "Kaye", "Kelcey", "Kellina", "Keri", "Keslie", "Kial", "Kimberlyn", "Kira", "Kissee", "Klarika", "Korella", "Krissy", "Kristina", "Kyle", "Lacey", "Lanette", "Lari", "Latrena", "Laurella", "Lauryn", "Lea", "Leeann", "Leigha", "Lenette", "Leonanie", "Lesley", "Letizia", "Leyla", "Libbi", "Lilas", "Lilllie", "Lindsay", "Linnell", "Lisette", "Liva", "Lizette", "Lona", "Loralie", "Loretta", "Lorine", "Lory", "Louisette", "Lucilia", "Luella", "Lurlene", "Lyndel", "Lynn", "Lyssa", "Maddie", "Madella", "Maegan", "Maggy", "Maisie", "Malissia", "Mamie", "Marcelia", "Marcille", "Margareta", "Margery", "Margy", "Maribelle", "Mariele", "Marillin", "Marissa", "Marjory", "Marley", "Marnie", "Martha", "Mary", "Maryl", "Matelda", "Maudie", "Mavis", "Mead", "Meggie", "Melanie", "Melisa", "Melli", "Melonie", "Meridel", "Merlina", "Merrili", "Michaelina", "Micki", "Mildred", "Milly", "Minna", "Mira", "Miriam", "Modestia", "Mommy", "Morgana", "Mozelle", "Myrah", "Myrtie", "Nalani", "Nanete", "Naoma", "Natalina", "Neala", "Nelie", "Nerte", "Netti", "Nickie", "Nicolle", "Ninette", "Noami", "Nolana", "Nora", "Norry", "Odessa", "Olga", "Olva", "Opalina", "Orel", "Ortensia", "Pam", "Paola", "Patti", "Pauline", "Pegeen", "Pepi", "Persis", "Phaedra", "Philis", "Phyllys", "Polly", "Pru", "Quintana", "Rafa", "Ramona", "Rani", "Raven", "Rebe", "Reeta", "Remy", "Rennie", "Rhiamon", "Riannon", "Rina", "Roanne", "Robina", "Rochella", "Romonda", "Ronny", "Rosabelle", "Rosamond", "Roselin", "Rosette", "Rowena", "Rozalie", "Rubetta", "Ruthe", "Sabrina", "Salli", "Samara", "Sapphire", "Sari", "Sayre", "Selia", "Serena", "Shandeigh", "Shannon", "Sharla", "Shawn", "Shea", "Shel", "Shellie", "Sherri", "Shirlene", "Sibeal", "Sidonia", "Simone", "Sissy", "Sonny", "Stacee", "Starlin", "Stephana", "Stevena", "Sula", "Susette", "Suzy", "Tabatha", "Tallia", "Tamarra", "Tamra", "Tanya", "Tatiania", "Tedra", "Teri", "Tess", "Thelma", "Thia", "Tiffanie", "Tilly", "Tiphanie", "Toma", "Tony", "Tove", "Tricia", "Trude", "Tybie", "Ursa", "Vale", "Valerie", "Van", "Velma", "Verile", "Vevay", "Vilhelmina", "Viole", "Vitoria", "Vivie", "Vyky", "Wanids", "Wileen", "Willie", "Wini", "Winonah", "Xenia", "Yevette", "Yovonnda", "Zaria", "Zitella", "Zorine"]

    static let lastNames = ["Aaberg", "Abisia", "Adalbert", "Adelia", "Adore", "Agbogla", "Aida", "Akeylah", "Albertine", "Aleda", "Alfons", "Alitta", "Allys", "Althea", "Amadas", "Ambert", "Ammann", "Anceline", "Anet", "Ann-Marie", "Anselmo", "Appel", "Ardehs", "Arianne", "Armando", "Arte", "Asher", "Atalanta", "Auberon", "Aun", "Avictor", "Babbette", "Bakki", "Bannasch", "Barimah", "Barthold", "Batha", "Beall", "Beeck", "Belinda", "Benil", "Berger", "Bernelle", "Beshore", "Bevis", "Bill", "Bixby", "Bleier", "Bobbette", "Bolan", "Booker", "Bosson", "Boycie", "Brand", "Breen", "Bridges", "Brittany", "Brookner", "Bryner", "Bullen", "Burkley", "Buskirk", "Cadmarr", "Callan", "Campbell", "Caputto", "Carlen", "Carny", "Cary", "Castorina", "Cavanagh", "Celio", "Chak", "Chari", "Chavaree", "Cherri", "Chiou", "Christiane", "Ciapha", "Claiborn", "Claudio", "Clerissa", "Cnut", "Cohligan", "Colpin", "Conlee", "Cooley", "Corena", "Corrinne", "Court", "Crean", "Cristy", "Culliton", "Cybill", "Dael", "Dam", "Daniell", "Dare", "Dasha", "Deach", "Deena", "Delmor", "Denise", "Derry", "Devlin", "Dib", "Dimitry", "Doane", "Domash", "Donn", "Dorion", "Doug", "Dreddy", "Duane", "Dunlavy", "Dustman", "Eada", "Ebneter", "Edita", "Effie", "Eisinger", "Electra", "Elison", "Elmer", "Elwaine", "Emily", "Engeddi", "Eran", "Erle", "Esbensen", "Ethben", "Eulalia", "Everara", "Ezri", "Faith", "Farlie", "Fausta", "Feinberg", "Fennie", "Festa", "Fillender", "Fisken", "Flo", "Follmer", "Foss", "Frannie", "Fredia", "Fries", "Fulmis", "Gae", "Gambell", "Garibull", "Gasparo", "Gayla", "Geminian", "Georgi", "Germano", "Giana", "Gilboa", "Gine", "Giulia", "Glinys", "Goeselt", "Gonta", "Gothar", "Grania", "Greenwell", "Griffiths", "Grote", "Gujral", "Guthry", "Hadleigh", "Haldeman", "Hamann", "Hanley", "Hardunn", "Harrington", "Hassi", "Haymo", "Heddie", "Heiskell", "Hendon", "Hepza", "Hersh", "Hey", "Hildie", "Hirschfeld", "Hogarth", "Holub", "Hornstein", "Howund", "Hujsak", "Hurlow", "Hyrup", "Iey", "Ilwain", "Ingraham", "Irina", "Isidoro", "Ivo", "Jacobba", "Jain", "Janenna", "Jarad", "Jayme", "Jegger", "Jennette", "Jerroll", "Jillayne", "Jochebed", "Johnsten", "Jordain", "Joub", "Juliana", "Justino", "Kaleena", "Kano", "Karlin", "Kata", "Katz", "Keelin", "Kellsie", "Kennie", "Kerrison", "Khosrow", "Kimberley", "Kirbie", "Klecka", "Knowlton", "Kong", "Kosiur", "Kreiner", "Krongold", "Kurtz", "LaSorella", "Lakin", "Landa", "Lanza", "Lasonde", "Lauer", "Lavery", "Leandre", "Leffert", "Lemire", "Leonardi", "Letch", "Lewie", "Lida", "Lim", "Linn", "Lissie", "Locklin", "Longley", "Lorie", "Louanne", "Luanne", "Ludie", "Lundt", "Lymn", "MacDonald", "Madalena", "Maffei", "Maibach", "Malek", "Malynda", "Manus", "Marder", "Mariand", "Mariska", "Marna", "Martha", "Marylou", "Mathis", "Mauretta", "Mayer", "McCowyn", "McLaurin", "Medea", "Melania", "Melloney", "Merc", "Merrie", "Michael", "Miguel", "Miller", "Minnie", "Mitzie", "Moll", "Monti", "Morlee", "Motteo", "Munafo", "Mya", "Nadabb", "Nancee", "Nassir", "Neal", "Nella", "Nesto", "Ng", "Nicolis", "Ninnetta", "Noemi", "Norma", "Nuncia", "Oberstone", "Odyssey", "Oletha", "Om", "Oralla", "Orlina", "Os", "Othilie", "O'Grady", "Painter", "Pantheas", "Parshall", "Patsis", "Payton", "Peirce", "Peony", "Perrine", "Pettit", "Philcox", "Phyllys", "Pinette", "Platon", "Pollyanna", "Possing", "Prevot", "Prowel", "Purpura", "Quint", "Radferd", "Raimund", "Rance", "Raseta", "Raynata", "Redmund", "Reine", "Renferd", "Reyna", "Ricardama", "Ridinger", "Riorsson", "Robbyn", "Rod", "Rokach", "Ronal", "Rosamond", "Roshan", "Rowell", "Rubin", "Rundgren", "Ruy", "Sadick", "Sale", "Samara", "Sanferd", "Sarine", "Sawyer", "Schechter", "Schonfield", "Scornik", "Secunda", "Selena", "Sera", "Sewellyn", "Shanly", "Shayn", "Shep", "Sheryle", "Sholom", "Siberson", "Sigfried", "Silvia", "Siskind", "Sladen", "Socher", "Sontich", "Spark", "Squires", "Stanzel", "Steffy", "Stew", "Stormie", "Stubbs", "Sumerlin", "Suzette", "Swords", "Tad", "Tallulah", "Tanny", "Tavia", "Telford", "Terle", "Thaddaus", "Theona", "Thomasine", "Thury", "Tillfourd", "Tisman", "Tomasine", "Tori", "Tracee", "Treulich", "Trix", "Tuchman", "Tybalt", "Ulick", "Uranie", "Utica", "Valeda", "Vanderhoek", "Vastha", "Verbenia", "Vi", "Vincenz", "Vittorio", "Von", "Waiter", "Walther", "Warton", "Webster", "Weitzman", "Wernsman", "Whiney", "Wilbur", "Willin", "Wini", "Witty", "Woods", "Wyndham", "Yard", "Yokoyama", "Yung", "Zampardi", "Zelda", "Zinah", "Zora"]

    static let urlDomains = ["apple.com", "www.google.com", "youtube.com", "play.google.com", "docs.google.com", "support.google.com", "www.blogger.com", "microsoft.com", "adobe.com", "wordpress.org", "mozilla.org", "en.wikipedia.org", "linkedin.com", "accounts.google.com", "plus.google.com", "vimeo.com", "github.com", "maps.google.com", "youtu.be", "drive.google.com", "bp.blogspot.com", "sites.google.com", "cloudflare.com", "googleusercontent.com", "vk.com", "istockphoto.com", "amazon.com", "dailymotion.com", "europa.eu", "bbc.co.uk", "medium.com", "creativecommons.org", "line.me", "facebook.com", "policies.google.com", "theguardian.com", "dropbox.com", "developers.google.com", "imdb.com", "live.com", "uol.com.br", "google.co.jp", "mail.ru", "nih.gov", "google.de", "fr.wikipedia.org", "whatsapp.com", "washingtonpost.com", "nytimes.com", "pt.wikipedia.org", "photos.google.com", "networkadvertising.org", "google.co.uk", "gstatic.com", "feedburner.com", "es.wikipedia.org", "t.me", "google.es", "google.com.br", "hugedomains.com", "globo.com", "forbes.com", "www.yahoo.com", "mail.google.com", "wikimedia.org", "slideshare.net", "news.yahoo.com", "msn.com", "amazon.co.jp", "bbc.com", "cnn.com", "paypal.com", "w3.org", "reuters.com", "myspace.com", "news.google.com", "apache.org", "samsung.com", "booking.com", "mediafire.com", "translate.google.com", "files.wordpress.com", "myaccount.google.com", "gnu.org", "www.wix.com", "buydomains.com", "terra.com.br", "tools.google.com", "goo.gl", "techcrunch.com", "ebay.com", "wikia.com", "thesun.co.uk", "rakuten.co.jp", "jimdofree.com", "change.org", "cpanel.net", "hp.com", "draft.blogger.com", "rt.com", "search.google.com", "hatena.ne.jp", "youronlinechoices.com", "telegraph.co.uk", "huffingtonpost.com", "pinterest.com", "abril.com.br", "books.google.com", "google.fr", "independent.co.uk", "twitter.com", "bloomberg.com", "ft.com", "ok.ru", "dailymail.co.uk", "amazon.de", "archive.org", "aboutads.info", "google.it", "aliexpress.com", "gravatar.com", "fandom.com", "ipv4.google.com", "wsj.com", "tinyurl.com", "marketingplatform.google.com", "picasaweb.google.com", "ted.com", "code.google.com", "google.ru", "nasa.gov", "foxnews.com", "aol.com", "un.org", "engadget.com", "oracle.com", "amazon.co.uk", "fb.com", "telegram.me", "plesk.com", "harvard.edu", "bing.com", "wired.com", "opera.com", "elpais.com", "groups.google.com", "issuu.com", "ig.com.br", "www.gov.uk", "nypost.com", "bit.ly", "get.google.com", "soundcloud.com", "steampowered.com", "lefigaro.fr", "de.wikipedia.org", "android.com", "scribd.com", "usatoday.com", "cnet.com", "orkut.com.br", "netflix.com", "themeforest.net", "picasa.google.com", "blackberry.com", "storage.googleapis.com", "usnews.com", "google.pl", "mega.nz", "alibaba.com", "shopify.com", "sciencemag.org", "pbs.org", "ucoz.ru", "bitly.com", "php.net", "loc.gov", "disqus.com", "news.com.au", "dan.com", "google.co.id", "businessinsider.com", "naver.com", "t.co", "pl.wikipedia.org", "mit.edu", "namecheap.com", "4shared.com", "sciencedirect.com", "digg.com", "welt.de", "vox.com", "trustpilot.com", "ox.ac.uk", "biglobe.ne.jp", "bt.com", "disney.com", "eventbrite.com", "gmail.com", "wikihow.com", "stanford.edu"]

}
