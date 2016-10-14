package
{
    import flash.display.*;

    public class RectBox extends Sprite
    {
        private var _w:Number;
        private var _h:Number;
        private var _borderColor:uint;
        private var _borderWidth:Number;

        public function RectBox(param1:Number, param2:Number, param3:uint = 11711154, param4:Number = 1)
        {
            this._w = param1 + param4;
            this._h = param2 + param4;
            this._borderColor = param3;
            this._borderWidth = param4;
            this.mouseEnabled = false;
            this.mouseChildren = false;
            this.init();
            return;
        }// end function

        private function init() : void
        {
            this.graphics.lineStyle(this._borderWidth, this._borderColor);
            this.graphics.lineTo(this._w, 0);
            this.graphics.lineTo(this._w, this._h);
            this.graphics.lineTo(0, this._h);
            this.graphics.lineTo(0, 0);
            return;
        }// end function

    }
}
