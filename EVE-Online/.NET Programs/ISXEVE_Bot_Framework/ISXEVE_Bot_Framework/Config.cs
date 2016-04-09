using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.IO;
using System.Xml.Serialization;

namespace ISXEVE_Bot_Framework
{
    [Serializable()]
    public class Config
    {
        /* Bot directory path */
        public static string FilePath = String.Format("{0}\\{1}\\{2}", InnerSpaceAPI.InnerSpace.Path,
            ".NET Programs", "ISXEVE_Bot_Framework");
        public static string ConfigFilePath = String.Format("{0}\\{1}", FilePath, "Config");

        /* Default account to use */
        public string DefaultAccount = String.Empty;

        /* insance */
        private static Config _instance;

        /* Auto start? */
        public bool AutoStart { get; set; }

        /* Try to create directories on initializaiton */
        public Config()
        {
            if (!Directory.Exists(FilePath))
                Directory.CreateDirectory(FilePath);
            if (!Directory.Exists(ConfigFilePath))
                Directory.CreateDirectory(ConfigFilePath);

            /* default-out settings */
            AutoStart = false;
        }

        /* Config property for trying to load a config or returning a new one */
        public static Config Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = Config.TryLoad();
                }
                return _instance;
            }
        }

        /* Save our configuration */
        public void Save()
        {
            /* Check for the directory */
            if (!Directory.Exists(FilePath))
            {
                Logging.OnLogMessage(this, "Save(): Directory " + FilePath + " not found, trying to create.");
                try
                {
                    Directory.CreateDirectory(FilePath);
                    Logging.OnLogMessage(this, "Save(): Directory created successfully.");
                }
                catch (Exception)
                {
                    Logging.OnLogMessage(this, "Save(): Directory could not be created. Try running this as an administrator.");
                    return;
                }
            }

            /* Serialize the settings */
            /* Use UserName for the fle name as it will be unique */
            using (FileStream fs = new FileStream(String.Format("{0}\\{1}",
                FilePath, "Config.xml"), FileMode.OpenOrCreate))
            {
                XmlSerializer xml = new XmlSerializer(typeof(Config));
                xml.Serialize(fs, _instance);
            }
        }

        /* Look for Config.xml and load it */
        private static Config TryLoad()
        {
            Logging.OnLogMessage(new int(), "Config.Load(): Attempting to load " + FilePath + "\\Config.xml");
            if (File.Exists(FilePath + "\\Config.xml"))
            {
                using (FileStream fs = new FileStream(FilePath + "\\Config.xml", FileMode.Open))
                {
                    XmlSerializer xs = new XmlSerializer(typeof(Config));
                    return (Config)xs.Deserialize(fs);
                }
            }
            else
            {
                Logging.OnLogMessage(new int(), "Config.Load(): Returning new config; no existing config found");
                return new Config();
            }
        }
    }

    [Serializable()]
    public class Settings
    {
        public static string FilePath = Config.ConfigFilePath;
        /* App-wide accessible settings instance */
        public static Settings ActiveSettings { get; set; }
        /* Active character */
        public CharacterSettings ActiveCharacter { get; set; }
        /* List of CharacterSettings, for character-specific settings */
        public List<CharacterSettings> Characters = new List<CharacterSettings>(3);

        public Settings()
        {
            
        }

        public void Save()
        {
            using (FileStream fs = new FileStream(String.Format("{0}\\{1}.xml", FilePath, this.UserName), FileMode.Create))
            {
                XmlSerializer xs = new XmlSerializer(typeof(Settings));
                Logging.OnLogMessage(this, "Settings.Save(): Saving settings for account " + this.UserName);
                xs.Serialize(fs, this);
            }
        }

        /* Open SelectCharacter form for selecting a character for editing or other purposes */
        public static void OpenSelectCharacter()
        {
            Forms.SelectCharacter f_SC = new Forms.SelectCharacter();
            f_SC.Show();
        }

        public string UserName { get; set; }
        public string PassWord { get; set; }
        public string DefaultCharIdentifier { get; set; }
    }

    public class CharacterSettings
    {
        public CharacterSettings()
        {

        }

        public CharacterSettings(string identifier)
        {
            Identifier = identifier;
        }

        public string Identifier { get; set; }

        public int CharId { get; set; }
        public string CharName { get; set; }
    }
}
