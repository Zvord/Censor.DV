namespace Censor
{
    using System.Text;
    public class MyStringBuilder
    {
        StringBuilder Builder;
        public int IndentSize = 4;
        public int IndentLevel {get; private set;} = 0;
        string Indent = null!;
        public void IncreaseIndentLevel()
        {
            IndentLevel++;
            UpdateIndent();
        }
        public void DecreaseIndentLevel()
        {
            if (IndentLevel > 1)
                IndentLevel--;
            UpdateIndent();
        }
        public MyStringBuilder(int indentSize = 4, int indentLevel = 0)
        {
            IndentSize = indentSize;
            IndentLevel = indentLevel;
            UpdateIndent();
            Builder = new();
        }
        public void UpdateIndent()
        {
            Indent = new(' ', IndentSize * IndentLevel);
        }
        public void AppendLine(string str = "")
        {
            str = $"{Indent}{str}";
            Builder.AppendLine(str);
        }
        override public string ToString() => Builder.ToString();
    }
}