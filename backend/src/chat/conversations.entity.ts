import { Entity, Column , PrimaryGeneratedColumn  ,JoinTable , OneToMany, ManyToMany } from "typeorm";
import { User } from "../users/users.entity";
import { Message } from "./message.entity";


@Entity()
export class Conversation {
    @PrimaryGeneratedColumn()
    id : string ;
    @ManyToMany(()=> User)
    @JoinTable ()
    participants : User [];
    @OneToMany (()=> Message , message=> message.conversationId)
    message : Message[];

    @Column ({ type : 'json' , nullable : false})
    lastMessage : Message ;
    
    @Column ({ default : 0 })
    unreadCount : number ;

    @Column()
    updateAt : Date ;
    

}
