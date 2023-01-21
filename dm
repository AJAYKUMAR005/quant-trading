https://www.techtrekking.com/how-to-convert-daily-time-series-data-into-weekly-and-monthly-using-pandas-and-python/
https://saralgyaan.com/posts/python-candlestick-chart-matplotlib-tutorial-chapter-11/
https://github.com/CodeByHarri/Candlestick-Trading-Analysis-Strategy/blob/master/Candlestick_Trading_Analysis_Predictions.ipynb
https://towardsdatascience.com/how-to-identify-japanese-candlesticks-patterns-in-python-b835d1cc72f7
# python_candlestick_chart.py

ohlc['SMA5'] = ohlc['Close'].rolling(5).mean()
ax.plot(ohlc['Date'], ohlc['SMA5'], color='green', label='SMA5')

fig.suptitle('Daily Candlestick Chart of NIFTY50 with SMA5')

plt.legend()

plt.show()

//@version=1 
//Defining Title and Name of Pine Script
study("Explosive Candles - Balasubramanian", overlay=true)

//-------------------------------------------------------------
// Script for Boring Candles  
//          Part 1: taking user input  
//          Part 2: Defining Variable and performing calculation 
//          Part 3: giving BLUE color to candle based on calculation
BcB_Ratio = input(60, title="Boring Candle Body <=(%)",minval=5, maxval=95)
C2BR=(abs(open-close)*100/abs(high-low))



//-------------------------------------------------------------
// Script for Explosive Candles  
//          Part 1: taking user input  
//          Part 2: Defining Variable and performing calculation 
//          Part 3: giving BLUE color to candle based on calculation
mp = input(1.5, title="Multiplier for Explo.Mov.",type=float)
ratio = input(60, title="Range-Body Ratio for Explo.Mov.")
cand = input(100, title="Average Number of Candles for Explo.Mov.")

range = atr(cand)
candr = abs(high-low)
bodyr = abs(open-close)
    
barcolor((bodyr/candr)>=ratio/100 and candr>=(range*mp) ? black:na, title="Explosive Move")

https://stackoverflow.com/questions/74411936/python-algo-trading-pandas-data-clean-up-and-call-from-another-function

//@version=4
study("Demand and Supply Candles-open", overlay=true, scale=scale.none)
//Input
Sensitivity = input(title="LegoutStrength", type=input.float, defval=1.5, minval=1.0, maxval=2.0, step=0.5)

//Variable Declaration
Candle_Range = high - low
Body_Range = abs(open - close )

//Explosive Candles Logic
Bar_Lookback = 100
Volatility = atr(Bar_Lookback)

//Sensitivity = 1.5
Strength = Volatility * Sensitivity
bar_before=1
barcolor(Body_Range > Candle_Range * 0.6 and Candle_Range >= Strength ? color.black : na)

//Boring Candles or Basing Candles Body Range <= 50% of Candle Range
barcolor(Body_Range <= Candle_Range * 0.5 ? color.blue : na)
         
         
         
// © sergaral

//@version=4
study("Leg Out &  Indecision", title="LOI", overlay = true)
length = input(title="Length", type=input.integer, defval=50, minval=1)
legout_scale = input(title="Legout scale", type=input.float, defval=2.5, minval=1)
indecision_body = input(title="Body less than %", type=input.float, defval=20.0, minval=1, maxval=100)

// Point legout 
// AVG. of the previous candles (given by the input 'length')
sum = 0.0
for i = 1 to length
    sum := sum + abs(close[i] - open[i])
avg = sum/length

// Plot legout which body is x AVG. (given by the input 'legout_scale')
barcolor (abs(close - open)>avg*legout_scale ? color.new(#ffad42, 5) : na, title="Leg Out")

// Indecision
// Colors candles with body less than 50% of body of candle range
candr = high-low
bodyr = open-close

bora = (bodyr/candr)*100

barcolor (bora >-indecision_body and bora <indecision_body ? color.new(#ffad42, 40) : na, title="Indecission")

 

# In[1]:


#shooting star is my friend's fav indicator
#the name is poetic and romantic
#it is merely a vertical flipped hammer
#hammer and shooting star could be confusing
#since both of them can be inverted
#i memorize them via a simple tune
#if u see thor (with hammer),price shall soar
#if u see star (shooting star),price shall fall
#details of shooting star can be found in investopedia
# https://www.investopedia.com/terms/s/shootingstar.asp
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import yfinance


# In[2]:


#criteria of shooting star
def shooting_star(data,lower_bound,body_size):

    df=data.copy()

    #open>close,red color
    df['condition1']=np.where(df['Open']>=df['Close'],1,0)

    #a candle with little or no lower wick
    df['condition2']=np.where(
        (df['Close']-df['Low'])<lower_bound*abs(
            df['Close']-df['Open']),1,0)

    #a candle with a small lower body
    df['condition3']=np.where(abs(
        df['Open']-df['Close'])<abs(
        np.mean(df['Open']-df['Close']))*body_size,1,0)

    #a long upper wick that is at least two times the size of the lower body
    df['condition4']=np.where(
        (df['High']-df['Open'])>=2*(
            df['Open']-df['Close']),1,0)

    #price uptrend
    df['condition5']=np.where(
        df['Close']>=df['Close'].shift(1),1,0)
    df['condition6']=np.where(
        df['Close'].shift(1)>=df['Close'].shift(2),1,0)

    #the next candle's high must stay 
    #below the high of the shooting star 
    df['condition7']=np.where(
        df['High'].shift(-1)<=df['High'],1,0)

    #the next candle's close below 
    #the close of the shooting star
    df['condition8']=np.where(
        df['Close'].shift(-1)<=df['Close'],1,0)
    
    return df


# In[3]:


#signal generation
#there are eight criteria according to investopedia
def signal_generation(df,method,
                      lower_bound=0.2,body_size=0.5,
                      stop_threshold=0.05,
                      holding_period=7):

    #get shooting star conditions
    data=method(df,lower_bound,body_size)

    #shooting star should suffice all conditions
    #in practise,you may find the definition too rigid
    #its important to relax a bit on the body size
    data['signals']=data['condition1']*data[
        'condition2']*data['condition3']*data[
        'condition4']*data['condition5']*data[
        'condition6']*data['condition7']*data[
        'condition8']

    #shooting star is a short signal
    data['signals']=-data['signals']
    
    #find exit position
    idxlist=data[data['signals']==-1].index
    for ind in idxlist:

        #entry point
        entry_pos=data['Close'].loc[ind]

        stop=False
        counter=0
        while not stop:
            ind+=1
            counter+=1

            #set stop loss/profit at +-5%
            if abs(data['Close'].loc[
                ind]/entry_pos-1)>stop_threshold:
                stop=True
                data['signals'].loc[ind]=1

            #set maximum holding period at 7 workdays
            if counter>=holding_period:
                stop=True
                data['signals'].loc[ind]=1

    #create positions
    data['positions']=data['signals'].cumsum()
    
    return data


# In[4]:


#since matplotlib remove the candlestick
#plus we dont wanna install mpl_finance
#we implement our own version
#simply use fill_between to construct the bar
#use line plot to construct high and low
def candlestick(df,ax=None,highlight=None,titlename='',
                highcol='High',lowcol='Low',
                opencol='Open',closecol='Close',xcol='Date',
                colorup='r',colordown='g',highlightcolor='y',
                **kwargs):  
    
    #bar width
    #use 0.6 by default
    dif=[(-3+i)/10 for i in range(7)]
    
    if not ax:
        ax=plt.figure(figsize=(10,5)).add_subplot(111)
    
    #construct the bars one by one
    for i in range(len(df)):
        
        #width is 0.6 by default
        #so 7 data points required for each bar
        x=[i+j for j in dif]
        y1=[df[opencol].iloc[i]]*7
        y2=[df[closecol].iloc[i]]*7

        barcolor=colorup if y1[0]>y2[0] else colordown
        
        #no high line plot if open/close is high
        if df[highcol].iloc[i]!=max(df[opencol].iloc[i],df[closecol].iloc[i]):
            
            #use generic plot to viz high and low
            #use 1.001 as a scaling factor
            #to prevent high line from crossing into the bar
            plt.plot([i,i],
                     [df[highcol].iloc[i],
                      max(df[opencol].iloc[i],
                          df[closecol].iloc[i])*1.001],c='k',**kwargs)
    
        #same as high
        if df[lowcol].iloc[i]!=min(df[opencol].iloc[i],df[closecol].iloc[i]):             
            
            plt.plot([i,i],
                     [df[lowcol].iloc[i],
                      min(df[opencol].iloc[i],
                          df[closecol].iloc[i])*0.999],c='k',**kwargs)
        
        #treat the bar as fill between
        plt.fill_between(x,y1,y2,
                         edgecolor='k',
                         facecolor=barcolor,**kwargs)
        
        if highlight:
            if df[highlight].iloc[i]==-1:
                plt.fill_between(x,y1,y2,
                         edgecolor='k',
                         facecolor=highlightcolor,**kwargs)

    #only show 5 xticks
    plt.xticks([])
    plt.grid(True)
    plt.title(titlename)


# In[5]:


#plotting the backtesting result
def plot(data,name):   
    
    #first plot is candlestick to showcase
    ax1=plt.subplot2grid((250,1),(0,0),
                         rowspan=120,
                         ylabel='Candlestick')
    candlestick(data,ax1,
                highlight='signals',
                highlightcolor='#FFFF00')

    #the second plot is the actual price 
    #with long/short positions as up/down arrows
    ax2=plt.subplot2grid((250,1),(130,0),
                         rowspan=120,
                         ylabel='£ per share',
                         xlabel='Date')
    ax2.plot(data.index,
             data['Close'],
             label=name)

    #long/short positions are attached to 
    #the real close price of the stock
    #set the line width to zero
    #thats why we only observe markers
    ax2.plot(data.loc[data['signals']==-1].index,
             data['Close'].loc[data['signals']==-1],
             marker='v',lw=0,c='r',label='short',
             markersize=10)
    ax2.plot(data.loc[data['signals']==1].index,
             data['Close'].loc[data['signals']==1],
             marker='^',lw=0,c='g',label='long',
             markersize=10)

    #only show five tickers
    plt.xticks(range(0,len(data),len(data)//5),
               data['Date'][0::len(data)//5].dt.date)
    
    plt.grid(True)
    plt.legend(loc='lower left')
    plt.tight_layout(pad=0.1)
    plt.show()


# In[6]:


def main():
    
    #initializing
    stdate='2020-01-01'
    eddate='2023-01-10'
    name='Infosys Limited'
    ticker='INFY.NS'

    df=yfinance.download(ticker,start=stdate,end=eddate)
    df.reset_index(inplace=True)
    df['Date']=pd.to_datetime(df['Date'])
    print(df.tail())
    #signal generation
    new=signal_generation(df,shooting_star)

    #get subset for better viz to highlight shooting star
    subset=new.loc[5268:5283].copy()
    subset.reset_index(inplace=True,drop=True)

    #viz
    plot(subset,name)


