/*************************************************************************
 * FILENAME : quene.h
 * FUNCTION : 通用32bits队列
 *************************************************************************/
b32 add4(b32,b32,b32);
b32 quenein(b32 top_,b32 bottom_,b32 front_,b32 back_,b32 elemt_ )
{
	b32 *top =(b32*) top_;
	b32 *bottom =(b32*)bottom_;
	b32 *front =(b32*)front_;
	b32 *back =(b32*)back_;
	b32 *elemt =(b32*)elemt_;
	b32 add=add4(*top,*bottom,*back);
	if(add==*front){
		return 0;
	}
	else{
		b32 *temp=(b32*)*back;
		*temp=*elemt;
		*back=add;
		return 1;
	}
}

b32 add4(b32 top,b32 bottom,b32 add)
{
	if((add+4)>=bottom)
		return (add+4)-top;
	else
		return add+4;
}

b32 queneout(b32 top_,b32 bottom_,b32 front_,b32 back_,b32 *elemt_)
{
    b32 *top =(b32*) top_;                                                                                                        
	b32 *bottom =(b32*)bottom_;
	b32 *front =(b32*)front_;
	b32 *back =(b32*)back_;
	//b32 *elemt =(b32*)elemt_;
	b32 *add=add4(*top,*bottom,*front);
	if(add==*back){
		return 0;
	}
	else{
		b32 *temp=(b32*)add;
		*elemt_=*temp;
		*front=add;
		return 1;
	}
}
